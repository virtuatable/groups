module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Groups < Arkaan::Utils::Controller

    load_errors_from __FILE__

    ['', '/rights', '/routes'].each do |path|
      before "/groups/:id#{path}" do
        @group = Arkaan::Permissions::Group.where(id: params['id']).first
      end
    end

    # @see https://github.com/jdr-tools/groups/wiki/Creating-a-group
    declare_route 'post', '/' do
      check_presence 'slug', route: 'creation'
      group = Arkaan::Permissions::Group.new(slug: params['slug'], is_default: params['is_default'] || false)
      if group.save
        item = Decorators::Group.new(group).to_h
        halt 201, {message: 'created', item: item}.to_json
      else
        model_error(group, 'creation')
      end
    end

    # @see https://github.com/jdr-tools/groups/wiki/Deleting-a-group
    declare_route 'delete', '/:id' do
      custom_error 404, 'deletion.group_id.unknown' if @group.nil?
      @group.delete
      halt 200, {message: 'deleted'}.to_json
    end

    # @see https://github.com/jdr-tools/groups/wiki/Getting-the-list-of-groups
    declare_route 'get', '/' do
      groups = Decorators::Group.decorate_collection(Arkaan::Permissions::Group.all)
      halt 200, {count: Arkaan::Permissions::Group.count, items: groups.map(&:to_h)}.to_json
    end

    # @see https://github.com/jdr-tools/groups/wiki/Obtaining-informations-about-a-group
    declare_route 'get', '/:id' do
      custom_error 404, 'informations.group_id.unknown' if @group.nil?
      halt 200, Decorators::Group.new(@group).to_json
    end

    declare_route 'put', '/:id' do
      custom_error 404, 'routes.group_id.unknown' if @group.nil?
      update_fields('slug', 'is_default')
      update_association('routes', Arkaan::Monitoring::Route)
      update_association('rights', Arkaan::Permissions::Right)
      halt 200, {message: 'updated', item: Decorators::Group.new(@group).to_h}.to_json
    end

    def update_association(association, klass)
      if params.has_key? association
        check_items(klass, association)
        mapped = params[association].map { |id| klass.find(id) }
        @group.send("#{association}=", mapped)
        @group.save
      end
    end

    def update_fields(*fields)
      fields.each do |field|
        @group.update_attribute(field, params[field]) if params.has_key? field
      end
    end

    def check_items(klass, association)
      singular = association.delete_suffix('s')
      return if params[association].nil? || params[association].empty?
      params[association].each do |item|
        custom_error 404, "#{association}.#{singular}_id.unknown" if klass.where(id: item).first.nil?
      end
    end
  end
end