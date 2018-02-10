module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Groups < Arkaan::Utils::Controller

    ['/:id', '/:id/rights', '/:id/routes'].each do |path|
      before path do
        @group = Arkaan::Permissions::Group.where(id: params['id']).first
        halt(404, {message: 'group_not_found'}.to_json) if @group.nil?
      end
    end

    declare_route 'get', '/' do
      groups = Decorators::Group.decorate_collection(Arkaan::Permissions::Group.all)
      halt 200, {count: Arkaan::Permissions::Group.count, items: groups.map(&:to_h)}.to_json
    end

    declare_route 'get', '/:id' do
      halt 200, Decorators::Group.new(@group).to_json
    end

    declare_route 'post', '/' do
      check_presence 'slug'
      group = Arkaan::Permissions::Group.new(slug: params['slug'])
      if group.save
        halt 201, {message: 'created'}.to_json
      else
        halt 422, {errors: group.errors.messages.values.flatten}.to_json
      end
    end

    declare_route 'patch', '/:id/rights' do
      check_items(Arkaan::Permissions::Right, 'right')
      @group.rights = []
      params['rights'].each do |right_id|
        @group.rights << Arkaan::Permissions::Right.where(id: right_id).first
      end
      @group.save
      halt 200, {message: 'updated'}.to_json
    end

    declare_route 'patch', '/:id/routes' do
      check_items(Arkaan::Monitoring::Route, 'route')
      @group.routes = []
      params['routes'].each do |route_id|
        @group.routes << Arkaan::Monitoring::Route.where(id: route_id).first
      end
      @group.save
      halt 200, {message: 'updated'}.to_json
    end

    declare_route 'delete', '/:id' do
      @group.delete
      halt 200, {message: 'deleted'}.to_json
    end

    def check_items(klass, singular)
      return if params["#{singular}s"].nil? || params["#{singular}s"].empty?
      params["#{singular}s"].each do |item|
        halt 404, {message: "#{singular}_not_found", id: item}.to_json if klass.where(id: item).first.nil?
      end
    end
  end
end