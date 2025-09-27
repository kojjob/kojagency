# KojAgency - Digital Agency Showcase Platform

[![Rails Version](https://img.shields.io/badge/Rails-8.0-red.svg)](https://rubyonrails.org/)
[![Ruby Version](https://img.shields.io/badge/Ruby-3.2.0-red.svg)](https://ruby-lang.org/)
[![Test Coverage](https://img.shields.io/badge/Coverage-90%2B-brightgreen.svg)](https://github.com/kojagency)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A sophisticated digital agency showcase platform designed to generate qualified leads through compelling case studies, professional presentation, and intelligent lead management. Built with Ruby on Rails 8, TailwindCSS, and modern development practices.

## 🚀 Overview

KojAgency is a comprehensive lead generation platform designed for digital agencies offering:
- **Web Development** - Custom web applications and SaaS platforms
- **Mobile Applications** - iOS and Android app development
- **Data Pipelines** - ETL systems and data engineering solutions
- **Analytics Platforms** - Business intelligence and data visualization

The platform combines technical excellence with proven business results to convert prospects into high-value clients.

## ✨ Key Features

### Public-Facing Features
- **📊 Project Portfolio** - Filterable case studies with measurable business metrics
- **💼 Service Pages** - Detailed offerings with pricing guidance and deliverables
- **🎯 Smart Lead Capture** - Intelligent forms with project estimators
- **📈 Case Studies** - Real business impact with ROI metrics
- **🏆 Social Proof** - Client testimonials and success metrics

### Lead Management System
- **🧮 AI-Powered Lead Scoring** - Multi-factor algorithm for lead prioritization
  - Budget weight: 35%
  - Timeline urgency: 25%
  - Project complexity: 20%
  - Lead quality: 20%
- **📞 CRM Integration** - HubSpot and Salesforce synchronization
- **📧 Email Automation** - Follow-up sequences based on lead behavior
- **📊 Analytics Dashboard** - Performance tracking and optimization insights

### Technical Excellence
- **🚄 Performance** - Sub-2-second page loads with optimized assets
- **🔒 Security** - SSL/TLS, rate limiting, input validation, security headers
- **📱 Responsive** - Mobile-first design with excellent UX across devices
- **🔍 SEO Optimized** - Meta tags, structured data, sitemap generation
- **♿ Accessibility** - WCAG compliance with semantic HTML

## 🛠️ Technology Stack

### Core Technologies
- **Backend**: Ruby on Rails 8.0 with modern conventions
- **Frontend**: TailwindCSS + Hotwire (Turbo + Stimulus)
- **Database**: PostgreSQL with Redis caching
- **Background Jobs**: Sidekiq for async processing
- **Testing**: RSpec with TDD approach (90%+ coverage)
- **Deployment**: Docker + Nginx + SSL

### Additional Tools
- **Version Control**: Git
- **Package Management**: Bundler (Ruby), npm (JavaScript)
- **Asset Pipeline**: Webpack + Babel
- **Code Quality**: RuboCop, ESLint
- **Monitoring**: Application Performance Monitoring (APM)

## 📋 Prerequisites

- Ruby 3.2.0 or higher
- Rails 8.0 or higher
- PostgreSQL 13 or higher
- Redis 6 or higher
- Node.js 18 or higher
- Docker (optional, for production deployment)

## 🚀 Quick Start

### Development Setup

1. **Clone the repository**
```bash
git clone https://github.com/kojagency/platform.git
cd platform
```

2. **Setup environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Install dependencies**
```bash
bundle install
npm install
```

4. **Setup database**
```bash
rails db:create
rails db:migrate
rails db:seed
```

5. **Start development server**
```bash
rails server
# In another terminal:
bundle exec sidekiq
```

Visit [http://localhost:3000](http://localhost:3000) to see the application.

## 📁 Project Structure

```
app/
├── controllers/     # Request handling and routing
├── models/         # Business logic and data models
├── services/       # Complex business operations
├── jobs/          # Background job processing
├── views/         # HTML templates and partials
├── javascript/    # Stimulus controllers and Turbo
└── assets/        # Stylesheets and images

spec/
├── models/        # Model unit tests
├── controllers/   # Controller tests
├── services/      # Service object tests
├── system/        # End-to-end tests
└── factories/     # Test data factories

config/
├── routes.rb      # URL routing configuration
├── database.yml   # Database configuration
└── application.rb # Application configuration

docker/
├── Dockerfile     # Container definition
├── docker-compose.yml
└── nginx.conf     # Web server configuration
```

## 🧪 Testing

We follow Test-Driven Development (TDD) with comprehensive test coverage:

```bash
# Run all tests
bundle exec rspec

# Run specific test types
bundle exec rspec spec/models
bundle exec rspec spec/controllers
bundle exec rspec spec/system

# Generate coverage report
COVERAGE=true bundle exec rspec
```

### Test Categories
- **Unit Tests**: Model validations and business logic
- **Integration Tests**: Controller actions and API endpoints
- **System Tests**: Full user workflows with JavaScript
- **Performance Tests**: Load testing and optimization verification

## 📊 Lead Scoring Algorithm

The platform uses a sophisticated lead scoring algorithm to prioritize prospects:

```ruby
score = (budget_weight * 35%) +     # Project budget range
        (timeline_weight * 25%) +   # Urgency/timeline
        (complexity_weight * 20%) + # Project complexity
        (quality_weight * 20%)      # Lead quality indicators

# Score interpretation:
# 80-100: High priority (immediate response)
# 60-79:  Medium priority (2-hour response)
# 40-59:  Low priority (next business day)
# 0-39:   Very low priority (weekly follow-up)
```

## 🚀 Deployment

### Docker Deployment

```bash
# Build production image
docker-compose -f docker-compose.production.yml build

# Run migrations
docker-compose exec web rails db:migrate RAILS_ENV=production

# Start services
docker-compose -f docker-compose.production.yml up -d
```

### Environment Variables

Key environment variables (see `.env.example` for full list):
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `SECRET_KEY_BASE` - Rails secret key
- `HUBSPOT_ACCESS_TOKEN` - HubSpot CRM integration
- `SMTP_HOST` - Email server configuration

## 🔧 Development Workflow

### Common Commands

```bash
# Database operations
rails db:migrate           # Run migrations
rails db:seed              # Seed sample data
rails db:reset             # Reset database

# Rails console
rails console              # Interactive console
rails c                    # Short version

# Background jobs
bundle exec sidekiq        # Start job processor

# Code quality
bundle exec rubocop        # Ruby linting
npm run lint               # JavaScript linting

# Asset compilation
rails assets:precompile    # Production assets
npm run build              # Build JavaScript
```

### Rake Tasks

```bash
# Project setup
rake db:seed:projects      # Seed sample projects
rake db:seed:clients       # Seed sample clients
rake db:seed:leads         # Generate test leads

# Maintenance
rake cleanup:old_leads     # Remove old test leads
rake cache:clear           # Clear all caches

# Health checks
rake health:check          # System health check
rake health:dependencies   # Check dependencies
```

## 📈 Performance Optimization

- **Database**: Query optimization with `includes`, counter caches, and indexes
- **Caching**: Multi-layer caching with Redis and fragment caching
- **Assets**: Compressed CSS/JS, optimized images, CDN integration
- **Background Jobs**: Async processing for emails and heavy operations
- **Monitoring**: APM integration for performance tracking

## 🔒 Security Features

- **Authentication**: Secure user authentication with bcrypt
- **Authorization**: Role-based access control
- **Input Validation**: Strong parameters and comprehensive validation
- **CSRF Protection**: Rails built-in CSRF tokens
- **Rate Limiting**: API and form submission limits
- **Security Headers**: CSP, HSTS, X-Frame-Options
- **SSL/TLS**: Enforced HTTPS in production

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](contributing_guide.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes (TDD approach)
4. Implement your feature
5. Ensure all tests pass (`bundle exec rspec`)
6. Submit a pull request

### Code Quality Standards
- Maintain 90%+ test coverage
- Follow Ruby/Rails conventions
- Update documentation for significant changes
- Consider performance impact
- Follow secure coding practices

## 📚 Documentation

- [Product Requirements Document](prd_document.md)
- [Contributing Guidelines](contributing_guide.md)
- [API Documentation](docs/api.md)
- [Deployment Guide](deployment_configuration.md)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/kojagency/platform/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kojagency/platform/discussions)
- **Email**: support@kojagency.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Success Metrics

### Business Goals
- **Lead Generation**: 10+ qualified leads per month
- **Conversion Rate**: 25%+ lead-to-consultation
- **Client Acquisition**: 3+ new clients annually
- **Revenue Impact**: 50%+ increase in inbound revenue

### Technical Goals
- **Performance**: 99.5%+ uptime, < 2s page loads
- **Security**: Zero security incidents
- **Quality**: 90%+ test coverage
- **SEO**: Top 5 rankings for target keywords

---

Built with ❤️ by KojAgency - *Showcasing technical excellence through measurable business results*