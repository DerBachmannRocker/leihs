module Procurement
  class Category < ActiveRecord::Base

    # only sub-categories
    has_many :category_inspectors, dependent: :delete_all
    has_many :inspectors, -> { order('firstname, lastname') },
             through: :category_inspectors,
             source: :user
    has_many :requests, dependent: :restrict_with_exception

    # only main-categories
    has_many :budget_limits, dependent: :delete_all, inverse_of: :category
    accepts_nested_attributes_for :budget_limits,
                                  allow_destroy: true

    # only sub-categories
    has_many :templates, -> { order(:article_name) }, dependent: :delete_all
    accepts_nested_attributes_for :templates,
                                  allow_destroy: true,
                                  reject_if: :all_blank

    belongs_to :parent, class_name: 'Category'
    has_many :children, class_name: 'Category',
                        foreign_key: :parent_id,
                        dependent: :restrict_with_exception
    accepts_nested_attributes_for :children,
                                  allow_destroy: true,
                                  reject_if: :all_blank

    validate do
      if parent
        if parent.parent
          errors.add :base, _('The parent category should be a main category')
        end
        if budget_limits.exists?
          errors.add :base, _('A sub category cannot have budget limits')
        end
      else
        if inspectors.exists?
          errors.add :base, _('A main category cannot have inspectors')
        end
      end
    end

    # TODO: belongs_to :procurement_attachment # image

    validates_presence_of :name
    validates_uniqueness_of :name

    def to_s
      if parent
        parent.name + ' > ' + name
      else
        name
      end
    end

    default_scope { order(:name) }

    scope :main, -> { where(parent_id: nil) }
    scope :leafs, -> { where.not(parent_id: nil) }

    ########################################################

    def inspectable_by?(user)
      category_inspectors.where(user_id: user).exists?
    end

    def inspectable_or_readable_by?(user)
      Procurement::Category.inspector_of_any_category_or_admin?(user)
    end

    class << self
      def inspector_of_any_category?(user)
        Procurement::CategoryInspector.where(user_id: user).exists?
      end

      def inspector_of_any_category_or_admin?(user)
        inspector_of_any_category?(user) or Procurement::Access.admin?(user)
      end
    end

  end
end