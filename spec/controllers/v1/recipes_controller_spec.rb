require "rails_helper"

describe V1::RecipesController, type: :controller do
  let(:owner) { create(:user, password: "opassword", password_confirmation: "opassword") }
  let(:o_token) { ApiSessionManager.new(owner.id).try_login("opassword")[:token] }
  let(:owner_headers) { { "User" => owner.id, "Authorization" => o_token } }

  let(:contributor) { create(:user, password: "cpassword", password_confirmation: "cpassword") }
  let(:c_token) { ApiSessionManager.new(contributor.id).try_login("cpassword")[:token] }
  let(:contributor_headers) { { "User" => contributor.id, "Authorization" => c_token } }

  let(:reader) { create(:user, password: "rpassword", password_confirmation: "rpassword") }
  let(:r_token) { ApiSessionManager.new(reader.id).try_login("rpassword")[:token] }
  let(:reader_headers) { { "User" => reader.id, "Authorization" => r_token } }

  let(:unassociated) { create(:user, password: "upassword", password_confirmation: "upassword") }
  let(:u_token) { ApiSessionManager.new(unassociated.id).try_login("upassword")[:token] }
  let(:unassoc_headers) { { "User" => unassociated.id, "Authorization" => u_token } }

  let(:random_headers) { [owner_headers, contributor_headers, reader_headers, unassoc_headers].sample }

  let(:cookbook) { owner.create_permission_record(Cookbook, { name: "Cool Cookbook"}) }

  before(:each) do
    contributor.allow_contributions_to(cookbook)
    if defined?(recipe)
      contributor.allow_contributions_to(recipe)
      reader.allow_to_read(recipe)
    end
  end

  describe "#create" do
    let(:create_request) { post :create, params: { cookbook_id: cookbook.id, name: "Test Recipe" } }

    describe "valid" do
      context "owns cookbook" do
        before { request.headers.merge(owner_headers) }

        it { expect{ create_request }.to change { contributor.recipes.count }.by 1 }
        it { expect{ create_request }.to change { owner.recipes.count }.by 1 }
        it { expect{ create_request }.to change{ contributor.user_recipe_roles.where(role: Role.reader).count }.by 1 }
        it { expect{ create_request }.to change{ owner.user_recipe_roles.where(role: Role.owner).count }.by 1 }


        it "returns serialized recipe" do
          response = create_request

          expect(response).to have_http_status(201)

          json_response = JSON.parse(response.body, symbolize_names: true)

          expect(json_response[:id]).to be_an(Integer)
          expect(json_response[:name]).to eq("Test Recipe")
          expect(json_response[:public]).to eq(false)
        end
      end

      xcontext "contributes to cookbook" do
        before { request.headers.merge(contributor_headers) }

        it { expect{ create_request }.to change { contributor.recipes.count }.by 1 }
        it { expect{ create_request }.to change { owner.recipes.count }.by 1 }
        it { expect{ create_request }.to change{ contributor.user_recipe_roles.where(role: Role.owner).count }.by 1 }
        it { expect{ create_request }.to change{ owner.user_recipe_roles.where(role: Role.owner).count }.by 1 }

        it "returns serialized recipe" do
          response = create_request
          json_response = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(201)

          expect(json_response[:id]).to be_an(Integer)
          expect(json_response[:name]).to eq("Test Recipe")
          expect(json_response[:public]).to eq(false)
        end
      end
    end

    xdescribe "invalid" do
      before { request.headers.merge(unassoc_headers) }

      it { expect{ create_request }.to change { owner.recipes.count }.by 0 }
      it { expect{ create_request }.to change{ owner.user_recipe_roles.where(role: Role.owner).count }.by 0 }
      it { expect{ create_request }.to have_http_status(404) }
    end
  end
end
