module Decorators
  class Group < Draper::Decorator
    delegate_all

    def to_h
      return {
        id: object.id.to_s,
        slug: object.slug,
        is_default: object.is_default,
        rights: object.rights.count,
        routes: object.routes.count
      }
    end

    def to_json
      return {
        id: object.id.to_s,
        slug: object.slug,
        is_default: object.is_default,
        rights: object.rights.map(&:id).map(&:to_s),
        routes: object.routes.map(&:id).map(&:to_s)
      }.to_json
    end
  end
end