# Digital Agency Showcase Platform

[![Rails Version](https://img.shields.io/badge/Rails-8.0-red.svg)](https://rubyonrails.org/)
[![Ruby Version](https://img.shields.io/badge/Ruby-3.2.0-red.svg)](https://ruby-lang.org/)
[![Test Coverage](https://img.shields.io/badge/Coverage-90%2B-brightgreen.svg)](https://github.com/your-org/agency-platform)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A sophisticated digital agency showcase platform designed to generate qualified leads through compelling case studies, professional presentation, and intelligent lead management. Built with Ruby on Rails 8, TailwindCSS, and modern development practices.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/your-org/agency-platform.git
cd agency-platform

# Setup environment
cp .env.example .env
# Edit .env with your configuration

# Install dependencies
bundle install
npm install

# Setup database
rails db:create db:migrate db:seed

# Start the application
rails server
```

Visit [http://localhost:3000](http://localhost:3000) to see the application.

## 📋 Prerequisites

- **Ruby**: 3.2.0 or higher
- **Rails**: 8.0 or higher
- **PostgreSQL**: 13 or higher
- **Redis**: 6 or higher
- **Node.js**: 18 or higher
- **Docker**: Optional, for production deployment

## 🏗️ Architecture Overview

### Technology Stack
- **Backend**: Ruby on Rails 8.0 with modern conventions
- **Frontend**: TailwindCSS + Hotwire (Turbo + Stimulus)
- **Database**: PostgreSQL with Redis caching
- **Background Jobs**: Sidekiq for async processing
- **Testing**: RSpec with comprehensive coverage
- **Deployment**: Docker + Nginx + SSL

### Key Features
- 📊 **Lead Scoring System**: AI-powered lead prioritization
- 📱 **Responsive Design**: Mobile-first, professional UI
- 🔒 **Security Focused**: Rate limiting, SSL, security headers
- ⚡ **Performance Optimized**: Sub-2-second page loads
- 🎯 **Conversion Optimized**: Built for lead generation
- 📈 **Analytics Integrated**: Track and optimize performance

## 🛠️ Development Setup

### Local Development

1. **Environment Setup**
```bash
# Install system dependencies (macOS)
brew install postgresql redis

# Start services
brew services start postgresql
brew services start redis
```

2. **Application Setup**
```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
npm install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Run tests
bundle exec rspec
```

3. **Start Development Server**
```bash
# Terminal 1: Rails server
rails server

# Terminal 2: Sidekiq (background jobs)
bundle exec sidekiq

# Terminal 3: TailwindCSS watch (optional)
npm run watch:css
```

### Docker Development

```bash
# Build and start all services
docker-compose up --build

# Run database migrations
docker-compose exec web rails db:migrate

# Run tests
docker-compose exec web bundle exec rspec
```

## 📁 Project Structure

```
app/
├── controllers/
│   ├── admin/              # Admin panel controllers
│   ├── api/                # API endpoints
│   └── ...                 # Public controllers
├── models/
│   ├── concerns/           # Shared model behaviors
│   └── ...                 # Domain models
├── services/               # Business logic services
├── jobs/                   # Background job classes
├── mailers/                # Email templates
└── views/
    ├── admin/              # Admin panel views
    ├── layouts/            # Layout templates
    └── ...                 # Public views

config/
├── environments/           # Environment configurations
├── initializers/           # App initialization
└── routes.rb              # URL routing

spec/
├── factories/              # Test data factories
├── models/                 # Model unit tests
├── controllers/            # Controller integration tests
├── system/                 # End-to-end tests
└── support/               # Test helper modules
```

## 🎯 Core Features

### Public Features
- **Landing Page**: Conversion-optimized homepage with clear value proposition
- **Portfolio**: Filterable case study showcase with business metrics
- **Services**: Detailed service offerings with pricing guidance
- **Contact**: Smart lead capture with project estimator
- **Blog**: Thought leadership content for SEO and credibility

### Admin Features
- **Project Management**: CRUD operations for case studies
- **Lead Management**: Dashboard with scoring and CRM integration
- **Content Management**: Services, technologies, testimonials
- **Analytics**: Performance tracking and optimization insights

### Automated Systems
- **Lead Scoring**: Multi-factor algorithm for lead prioritization
- **CRM Integration**: HubSpot/Salesforce synchronization
- **Email Automation**: Follow-up sequences based on lead behavior
- **Performance Monitoring**: Health checks and metrics collection

## 🔧 Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
# Database
DATABASE_URL=postgresql://username:password@localhost/agency_development
REDIS_URL=redis://localhost:6379/0

# Application
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_here

# Email (production)
SMTP_HOST=your_smtp_host
SMTP_USERNAME=your_smtp_username
SMTP_PASSWORD=your_smtp_password

# CRM Integration
HUBSPOT_ACCESS_TOKEN=your_hubspot_token
SALESFORCE_CLIENT_ID=your_salesforce_client_id
SALESFORCE_CLIENT_SECRET=your_salesforce_client_secret

# Analytics
GOOGLE_ANALYTICS_ID=GA_MEASUREMENT_ID
```

### Database Configuration

The application uses PostgreSQL with the following key tables:
- `projects`: Case studies and portfolio items
- `clients`: Client information and relationships
- `leads`: Prospect information with scoring
- `services`: Service offerings and details
- `technologies`: Tech stack and proficiency

## 🧪 Testing

We maintain comprehensive test coverage using RSpec:

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
- **Unit Tests**: Model validations, business logic
- **Integration Tests**: Controller actions, API endpoints
- **System Tests**: Full user workflows with JavaScript
- **Performance Tests**: Load testing, optimization verification

## 🚀 Deployment

### Production Deployment with Docker

1. **Build Production Image**
```bash
docker-compose -f docker-compose.production.yml build
```

2. **Deploy to Server**
```bash
# Copy files to server
scp -r . user@server:/var/www/agency-platform

# On server: start services
docker-compose -f docker-compose.production.yml up -d

# Run migrations
docker-compose exec web rails db:migrate RAILS_ENV=production
```

### Environment-Specific Setup

**Staging Environment**:
```bash
RAILS_ENV=staging rails db:migrate
RAILS_ENV=staging rails assets:precompile
```

**Production Environment**:
```bash
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails assets:precompile
```

## 📊 Performance Optimization

### Key Performance Metrics
- **Page Load Speed**: < 2 seconds target
- **Database Queries**: N+1 prevention with `includes`
- **Caching Strategy**: Redis for sessions, fragments, and data
- **Asset Optimization**: Compressed CSS/JS, optimized images
- **CDN Integration**: Global content delivery

### Monitoring & Health Checks

Health check endpoint: `GET /health`

```json
{
  "status": "healthy",
  "checks": {
    "database": { "status": "healthy" },
    "redis": { "status": "healthy" },
    "disk_space": { "status": "healthy" }
  }
}
```

## 🔒 Security

### Security Measures Implemented
- **SSL/TLS**: Enforced HTTPS in production
- **Rate Limiting**: API and form submission limits
- **Input Validation**: Comprehensive parameter filtering
- **Security Headers**: CSP, HSTS, X-Frame-Options
- **Authentication**: Secure admin panel access
- **Data Protection**: PII handling and GDPR compliance

### Security Auditing
```bash
# Run security audit
bundle audit --update

# Check for vulnerabilities
npm audit --audit-level moderate
```

## 📈 Lead Scoring Algorithm

The platform uses a sophisticated lead scoring algorithm:

```ruby
# Scoring factors (weighted)
score = (budget_weight * 35%) +     # Project budget range
        (timeline_weight * 25%) +   # Urgency/timeline
        (complexity_weight * 20%) + # Project complexity
        (quality_weight * 10%) +    # Lead quality indicators
        (completeness_weight * 10%) # Form completeness

# Score interpretation
# 80-100: High priority (immediate response)
# 60-79:  Medium priority (2-hour response)
# 40-59:  Low priority (next business day)
# 0-39:   Very low priority (weekly follow-up)
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Implement your feature
5. Ensure all tests pass (`bundle exec rspec`)
6. Submit a pull request

### Code Quality Standards
- **Test Coverage**: Maintain 90%+ coverage
- **Code Style**: Follow Ruby/Rails conventions
- **Documentation**: Update docs for significant changes
- **Performance**: Consider impact on load times
- **Security**: Follow secure coding practices

## 📚 Additional Resources

- **Project Requirements**: [PRD.md](PRD.md)
- **AI Development Guide**: [claude.md](claude.md)
- **API Documentation**: [API.md](docs/API.md)
- **Deployment Guide**: [DEPLOYMENT.md](docs/DEPLOYMENT.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/agency-platform/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/agency-platform/discussions)
- **Email**: tech-support@yourcompany.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Success Metrics

### Business Goals
- **Lead Generation**: 10+ qualified leads per month
- **Conversion Rate**: 25%+ lead-to-consultation conversion
- **Client Acquisition**: 3+ new clients annually from platform
- **Revenue Impact**: 50%+ increase in inbound revenue

### Technical Goals
- **Performance**: 99.5%+ uptime, < 2s page loads
- **Security**: Zero security incidents
- **Quality**: 90%+ test coverage, clean code architecture
- **SEO**: Top 5 rankings for target keywords

---

Built with ❤️ by [Your Digital Agency Name]

*Showcasing technical excellence through measurable business results.*
