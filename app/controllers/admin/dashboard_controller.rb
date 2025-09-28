module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_admin!
    before_action :require_admin

    def index
      # Key Performance Indicators
      @stats = {
        leads: {
          total: Lead.count,
          this_week: Lead.where(created_at: 1.week.ago..Time.current).count,
          this_month: Lead.where(created_at: 1.month.ago..Time.current).count,
          high_priority: Lead.high_priority.count,
          conversion_rate: calculate_conversion_rate
        },
        users: {
          total: User.count,
          admins: User.admin.count,
          regular: User.where(admin: false).count,
          recent: User.where(created_at: 1.month.ago..Time.current).count
        },
        blog: {
          total: BlogPost.count,
          published: BlogPost.published.count,
          this_month: BlogPost.where(created_at: 1.month.ago..Time.current).count,
          views_this_month: calculate_blog_views
        },
        activity: recent_activity
      }

      # Recent leads requiring attention
      @recent_leads = Lead.order(created_at: :desc).limit(10)

      # High priority leads
      @priority_leads = Lead.high_priority.order(created_at: :desc).limit(5)

      # Performance metrics
      @performance_data = {
        lead_trends: weekly_lead_trends,
        conversion_funnel: conversion_funnel_data,
        top_sources: top_lead_sources
      }
    end

    private

    def calculate_conversion_rate
      total_leads = Lead.count
      return 0 if total_leads.zero?

      converted_leads = Lead.qualified.count
      ((converted_leads.to_f / total_leads) * 100).round(1)
    end

    def calculate_blog_views
      # Placeholder - would integrate with analytics service
      BlogPost.published.sum { |post| rand(100..1000) }
    end

    def recent_activity
      activities = []

      # Recent leads
      Lead.limit(5).order(created_at: :desc).each do |lead|
        activities << {
          type: 'lead',
          message: "New lead: #{lead.full_name} (#{lead.company})",
          time: lead.created_at,
          priority: lead.priority_level,
          link: admin_lead_path(lead)
        }
      end

      # Recent user registrations
      User.limit(3).order(created_at: :desc).each do |user|
        activities << {
          type: 'user',
          message: "New user registered: #{user.name}",
          time: user.created_at,
          priority: 'medium',
          link: '#'
        }
      end

      # Recent blog posts
      BlogPost.limit(3).order(created_at: :desc).each do |post|
        activities << {
          type: 'blog',
          message: "Blog post: #{post.title}",
          time: post.created_at,
          priority: 'low',
          link: blog_post_path(post)
        }
      end

      activities.sort_by { |a| a[:time] }.reverse.first(10)
    end

    def weekly_lead_trends
      trends = []
      6.times do |i|
        week_start = (6 - i).weeks.ago.beginning_of_week
        week_end = week_start.end_of_week
        trends << {
          week: week_start.strftime('%b %d'),
          leads: Lead.where(created_at: week_start..week_end).count,
          qualified: Lead.qualified.where(created_at: week_start..week_end).count
        }
      end
      trends
    end

    def conversion_funnel_data
      total = Lead.count
      contacted = Lead.contacted.count
      qualified = Lead.qualified.count

      {
        total: total,
        contacted: contacted,
        qualified: qualified,
        contacted_rate: total > 0 ? ((contacted.to_f / total) * 100).round(1) : 0,
        qualified_rate: contacted > 0 ? ((qualified.to_f / contacted) * 100).round(1) : 0
      }
    end

    def top_lead_sources
      Lead.group(:source).count.sort_by { |_, count| -count }.first(5)
    end
  end
end