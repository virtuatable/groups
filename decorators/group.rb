# frozen_string_literal: true

module Decorators
  # Decorator for a group, wrapping its attributes
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Group < Draper::Decorator
    delegate_all

    def to_h
      {
        id: id.to_s,
        slug: slug,
        is_default: is_default,
        rights: rights.count,
        routes: routes.count
      }
    end

    def to_json(*_args)
      {
        id: id.to_s,
        slug: slug,
        is_default: is_default,
        rights: rights.map(&:id).map(&:to_s),
        routes: routes.map(&:id).map(&:to_s)
      }.to_json
    end
  end
end
