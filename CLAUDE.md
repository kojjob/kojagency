# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Digital Agency Showcase Platform built with Ruby on Rails 8.0, designed to generate qualified leads through compelling case studies and professional presentation. The platform uses a sophisticated lead scoring algorithm and integrates with CRM systems for automated sales workflows.

**Note**: The Rails application scaffold has already been generated. The project structure includes the core models, controllers, and test suite as defined in the documentation files.

## Common Development Commands

### Running the Application
```bash
# Start Rails server
rails server

# Start with specific port
rails server -p 3001

# Run in production mode locally
RAILS_ENV=production rails server

# Run Rails console
rails console

# Run Rails console in sandbox mode (rollback changes on exit)
rails console --sandbox
```

### Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test categories
bundle exec rspec spec/models
bundle exec rspec spec/controllers
bundle exec rspec spec/system

# Run a single test file
bundle exec rspec spec/models/lead_spec.rb

# Run a specific test example (line number)
bundle exec rspec spec/models/lead_spec.rb:42

# Generate test coverage report
COVERAGE=true bundle exec rspec
```

### Database Operations
```bash
# Run pending migrations
rails db:migrate

# Check migration status
rails db:migrate:status

# Rollback last migration
rails db:rollback

# Rollback specific number of migrations
rails db:rollback STEP=3

# Reset database (drop, create, migrate, seed)
rails db:reset

# Seed database with sample data
rails db:seed

# Drop and recreate database from schema.rb
rails db:schema:load
```

### Asset Management
```bash
# Precompile assets for production
rails assets:precompile

# Watch for TailwindCSS changes (if configured)
npm run watch:css
```

### Background Jobs
```bash
# Start Sidekiq for background job processing
bundle exec sidekiq

# Monitor Sidekiq queues
bundle exec sidekiq -q high -q default -q low
```

### Code Quality
```bash
# Run RuboCop for Ruby code style
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -A

# Check for security vulnerabilities
bundle audit --update
```

## High-Level Architecture

### Domain Model Structure
The application follows Domain-Driven Design principles with the following core entities:

- **Project**: Case studies showcasing completed work, with metrics and client testimonials
- **Client**: Organizations that have engaged the agency's services
- **Lead**: Potential clients captured through the contact form, with automated scoring
- **Service**: Types of services offered (web development, mobile apps, data pipelines, analytics platforms, consulting)
- **Technology**: Technical stack expertise (Rails, React, data engineering tools, etc.)
- **Testimonial**: Client feedback linked to projects

### Lead Scoring Algorithm
The platform implements a sophisticated lead scoring system that automatically prioritizes leads based on:
- Budget range (35% weight)
- Timeline urgency (25% weight)
- Project complexity (20% weight)
- Lead quality indicators (20% weight)

Leads scoring 80+ are high priority with immediate response, 60-79 are medium priority with 2-hour response, and below 60 are lower priority.

### Service Architecture
The application uses Service Objects pattern for complex business logic:
- `LeadScoringService`: Calculates lead scores based on multiple factors
- `LeadWorkflowJob`: Handles automated follow-up and CRM integration
- Additional services for email automation and data synchronization

The agency's service offerings include:
- **Web Development**: Custom web applications with modern frameworks
- **Mobile Development**: Native iOS and Android applications
- **Data Engineering**: Building data pipelines, ETL processes, and data warehouses
- **Analytics Platforms**: Custom dashboards, business intelligence solutions
- **Technical Consulting**: Architecture design, technology strategy

### Testing Strategy
The project follows Test-Driven Development (TDD) with comprehensive coverage:
- Unit tests for models and business logic
- Integration tests for controllers and API endpoints
- System tests for critical user workflows
- Factory Bot for test data generation
- Shoulda Matchers for clean validation tests

### Key Technical Patterns

1. **Friendly URLs**: Uses FriendlyId gem for SEO-friendly slugs on projects and services
2. **Soft Deletes**: Paranoia gem for safe record deletion with recovery capability
3. **Rich Associations**: Complex many-to-many relationships through join tables
4. **Enum Usage**: Status fields use Rails enums for type safety
5. **Scope Chains**: Extensive use of ActiveRecord scopes for query composition

### External Integrations
- **CRM Systems**: HubSpot and Salesforce for lead management
- **Email Marketing**: Automated sequences based on lead scoring
- **Analytics**: Google Analytics and Tag Manager integration
- **Performance Monitoring**: Health check endpoints at `/health`

## Development Workflow

When working on new features:
1. Create a feature branch from main
2. Write tests first (TDD approach)
3. Implement the feature
4. Ensure all tests pass
5. Create a pull request with clear description

When fixing bugs:
1. Write a failing test that reproduces the bug
2. Fix the implementation
3. Verify the test passes
4. Check for any related issues

## Performance Considerations

- Database queries are optimized with `includes` to prevent N+1 problems
- Redis caching is used for session storage and fragment caching
- Images are processed and optimized with Active Storage
- Page load target is under 2 seconds
- Background jobs handle time-intensive operations

## Security Measures

- Strong parameters enforced on all controllers
- CSRF protection enabled
- Rate limiting on public endpoints
- Input validation and sanitization throughout
- SSL/TLS required in production