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
  end
end