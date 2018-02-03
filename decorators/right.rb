module Decorators
  class Right < Draper::Decorator
    delegate_all

    def to_h
      return {
        id: object.id.to_s,
        slug: object.slug
      }
    end
  end
end