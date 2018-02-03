module Decorators
  class Group < Draper::Decorator
    delegate_all

    def to_h
      return {
        id: object.id.to_s,
        slug: object.slug,
        rights: object.rights.count,
        routes: object.routes.count
      }
    end

    def to_json
      return {
        id: object.id.to_s,
        slug: object.slug,
        rights: Decorators::Right.decorate_collection(object.rights).map(&:to_h)
      }.to_json
    end
  end
end