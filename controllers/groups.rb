module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Groups < Arkaan::Utils::Controller
    declare_route 'post', '/' do
      check_presence 'slug'
      category = Arkaan::Permissions::Group.new(slug: params['slug'])
      if category.save
        halt 201, {message: 'created'}.to_json
      else
        halt 422, {errors: category.errors.messages.values.flatten}.to_json
      end
    end

    declare_route 'patch', '/:id/rights' do
      group = Arkaan::Permissions::Group.where(id: params['id']).first
      if group.nil?
        halt 404, {message: 'group_not_found'}.to_json
      else
        check_items(Arkaan::Permissions::Right, 'right')
        group.rights = []
        params['rights'].each do |right_id|
          group.rights << Arkaan::Permissions::Right.where(id: right_id).first
        end
        group.save
        halt 200, {message: 'updated'}.to_json
      end
    end

    def check_items(klass, singular)
      return if params["#{singular}s"].nil? || params["#{singular}s"].empty?
      params["#{singular}s"].each do |item|
        halt 404, {message: "#{singular}_not_found", id: item}.to_json if klass.where(id: item).first.nil?
      end
    end
  end
end