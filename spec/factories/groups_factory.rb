FactoryGirl.define do
  factory :empty_group, class: Arkaan::Permissions::Group do
    factory :group do
      _id 'group_id'
      slug 'test_group'

      factory :other_group do
        _id 'other_group_id'
      end
    end
  end
end