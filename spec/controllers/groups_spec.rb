RSpec.describe Controllers::Groups do

  before do
    DatabaseCleaner.clean
  end

  let!(:group) { create(:group) }
  let!(:category) { create(:category) }
  let!(:account) { create(:account) }
  let!(:right) {
    tmp_right = create(:right, category: category)
    tmp_right.groups << group
    tmp_right.save
    tmp_right
  }
  let!(:application) { create(:application, creator: account) }
  let!(:gateway) { create(:gateway) }

  def app
    Controllers::Groups.new
  end

  describe 'GET /' do
    describe 'nominal case' do
      before do
          get '/', {app_key: 'test_key', token: 'test_token'}
      end
      it 'Returns a OK (200) status code when querying for the list of groups' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body for the list of groups' do
        expect(JSON.parse(last_response.body)).to eq({
          'count' => 1,
          'items' => [
            {
              'id' => group.id.to_s,
              'slug' => 'test_group',
              'rights' => 1,
              'routes' => 0
            }
          ]
        })
      end
    end
    describe 'bad request errors' do
      describe 'no token error' do
        before do
          get '/', {app_key: 'test_key'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no application key error' do
        before do
          get '/', {token: 'test_token'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the application key' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a application key' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'application not found' do
        before do
          get '/', {token: 'test_token', app_key: 'another_key'}
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          get '/', {token: 'other_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
  end
  describe 'POST /' do
    describe 'in the nominal case' do
      before do
        post '/', {app_key: 'test_key', token: 'test_token', slug: 'test_other_right'}
      end
      it 'gives the correct status code when successfully creating a right' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct body when the right is successfully created' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'created'})
      end
    end
    describe 'unprocessable entity errors' do
      describe 'already existing slug error' do
        before do
          post '/', {app_key: 'test_key', token: 'test_token', slug: 'test_group'}
        end
        it 'gives the correct status code when creating a right with an already existing slug' do
          expect(last_response.status).to be 422
        end
        it 'returns the correct body when creating a right with an already existing slug' do
          expect(JSON.parse(last_response.body)).to eq({'errors' => ['group.slug.uniq']})
        end
      end
    end
    describe 'bad request errors' do
      describe 'slug not given error' do
        before do
          post '/', {app_key: 'test_key', token: 'test_token'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the slug' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a slug' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no token error' do
        before do
          post '/', {app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no application key error' do
        before do
          post '/', {token: 'test_token'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the application key' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a application key' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'application not found' do
        before do
          post '/', {token: 'test_token', app_key: 'another_key'}.to_json
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          post '/', {token: 'other_token', app_key: 'test_key'}.to_json
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
  end
  describe 'PATCH /:id/rights' do
    describe 'nominal case' do
      let!(:other_group) { create(:group, slug: 'other_slug_group') }
      let!(:other_right) { create(:right, slug: 'other_slug_right', category: category) }
      before do
        patch "/#{other_group.id.to_s}/rights", {token: 'test_token', app_key: 'test_key', rights: [right.id.to_s]}
      end
      it 'Returns a OK (200) response code if the right has successfully been appended to the group' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body if the right has successfully been appended' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
      end
      it 'has linked one right to the group' do
        expect(other_group.reload.rights.count).to be 1
      end
      it 'has linked the right right to the group' do
        expect(other_group.reload.rights.first.slug).to eq 'test_right'
      end
      describe 'overwriting the rights in a group' do
        before do
          patch "/#{other_group.id.to_s}/rights", {token: 'test_token', app_key: 'test_key', rights: [other_right.id.to_s]}
        end
        it 'Returns a OK (200) response code when overwriting the rights' do
          expect(last_response.status).to be 200
        end
        it 'returns the correct body when overwriting the rights' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
        end
        it 'has overwritten the rights associated to the group' do
          expect(other_group.reload.rights.count).to be 1
        end
        it 'has changed the right attached to this group' do
          expect(other_group.reload.rights.first.slug).to eq 'other_slug_right'
        end
      end
    end
    describe 'bad request errors' do
      describe 'no token error' do
        before do
          patch "/#{group.id.to_s}/rights", {app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no application key error' do
        before do
          patch "/#{group.id.to_s}/rights", {token: 'test_token'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the application key' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a application key' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'group not found' do
        before do
          patch "/any_unknown_group/rights", {token: 'test_token', app_key: 'test_key', rights: []}
        end
        it 'Raises a not found (404) error when the group does not exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body if the group does not exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'group_not_found'})
        end
      end
      describe 'one of the rights has not been found' do
        let!(:other_group) { create(:group, slug: 'other_slug_group') }
        before do
          patch "/#{other_group.id.to_s}/rights", {token: 'test_token', app_key: 'test_key', rights: [right.id.to_s, 'any_other_right']}
        end
        it 'Raises a not found (404) error when a right unique identifier is not found' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body if a right is not found' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'right_not_found', 'id' => 'any_other_right'})
        end
        it 'has not associated a right with the given group' do
          expect(other_group.rights.count).to be 0
        end
      end
      describe 'application not found' do
        before do
          patch "/#{group.id.to_s}/rights", {token: 'test_token', app_key: 'another_key'}.to_json
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          patch "/#{group.id.to_s}/rights", {token: 'other_token', app_key: 'test_key'}.to_json
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
  end
end