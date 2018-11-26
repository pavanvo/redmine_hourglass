module Hourglass
  class TimeTrackerQuery < Query
    include QueryBase

    set_available_columns(
        comments: {},
        user: {sortable: lambda { User.fields_for_order_statement }},
        date: {sortable: "#{queried_class.table_name}.start", groupable: sql_timezoned_date("#{queried_class.table_name}.start")},
        start: {},
        hours: {},
        project: {sortable: "#{Project.table_name}.name", groupable: "#{Project.table_name}.id"},
        activity: {sortable: "#{TimeEntryActivity.table_name}.position", groupable: "#{TimeEntryActivity.table_name}.id"},
        issue: {sortable: "#{Issue.table_name}.subject", groupable: "#{Issue.table_name}.id"},
        fixed_version: {sortable: lambda { Version.fields_for_order_statement }, groupable: "#{Issue.table_name}.fixed_version_id"}
    )

    def initialize_available_filters
      add_user_filter
      add_date_filter
      add_issue_filter
      if project
        add_sub_project_filter unless project.leaf?
      elsif all_projects.any?
        add_project_filter
      end
      add_activity_filter
      add_fixed_version_filter
      add_comments_filter
      add_associations_custom_fields_filters :user, :project, :activity, :fixed_version
      add_custom_fields_filters issue_custom_fields, :issue
    end

    def available_columns
      @available_columns ||= self.class.available_columns.dup.tap do |available_columns|
        {
            time_entry: TimeEntryCustomField,
            issue: issue_custom_fields,
            project: ProjectCustomField,
            user: UserCustomField,
            fixed_version: VersionCustomField

        }.each do |association, custom_field_scope|
          custom_field_scope.visible.each do |custom_field|
            available_columns << QueryAssociationCustomFieldColumn.new(association, custom_field)
          end
        end
      end
    end

    def default_columns_names
      @default_columns_names ||= [:user, :date, :start, :hours, :project, :issue, :activity, :comments]
    end

    def base_scope
      super.eager_load(:user, :project, :activity, issue: :fixed_version)
    end

    def sql_for_fixed_version_id_field(field, operator, value)
      sql_for_field(field, operator, value, Issue.table_name, 'fixed_version_id')
    end

    def sql_for_custom_field(*args)
      result = super
      result.gsub! /#{queried_table_name}\.(fixed_version)_id/ do
        groupable_columns.select { |c| c.name === $1.to_sym }.first.groupable
      end
      result
    end

    def has_through_associations
      %i(fixed_version)
    end
  end
end
