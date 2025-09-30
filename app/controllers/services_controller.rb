class ServicesController < ApplicationController
  def index
    @services = [
      {
        id: 1,
        title: "Web Development",
        slug: "web-development",
        icon: "web",
        short_description: "Custom web applications and SaaS platforms built with cutting-edge technologies",
        description: "We build scalable, secure, and high-performance web applications tailored to your business needs. From simple websites to complex SaaS platforms, we leverage modern frameworks and best practices to deliver exceptional digital experiences.",
        features: [
          "Custom Web Applications",
          "SaaS Platform Development",
          "E-commerce Solutions",
          "Progressive Web Apps (PWA)",
          "API Development & Integration",
          "Cloud Deployment & DevOps"
        ],
        technologies: [ "Ruby on Rails", "React", "Vue.js", "Node.js", "PostgreSQL", "AWS" ],
        process: [
          "Requirements Analysis",
          "UI/UX Design",
          "Agile Development",
          "Testing & QA",
          "Deployment",
          "Maintenance & Support"
        ],
        benefits: [
          "Scalable Architecture",
          "Security Best Practices",
          "Performance Optimization",
          "Mobile Responsive",
          "SEO Friendly",
          "24/7 Support"
        ]
      },
      {
        id: 2,
        title: "Mobile Development",
        slug: "mobile-development",
        icon: "mobile",
        short_description: "Native and cross-platform mobile apps that delight users",
        description: "Create engaging mobile experiences that your users will love. We develop native iOS and Android apps as well as cross-platform solutions that work seamlessly across all devices.",
        features: [
          "Native iOS Development",
          "Native Android Development",
          "Cross-platform Apps",
          "Mobile UI/UX Design",
          "App Store Optimization",
          "Push Notifications & Analytics"
        ],
        technologies: [ "Swift", "Kotlin", "React Native", "Flutter", "Firebase", "GraphQL" ],
        process: [
          "Concept & Strategy",
          "Wireframing & Prototyping",
          "Development & Testing",
          "App Store Submission",
          "Launch Support",
          "Updates & Maintenance"
        ],
        benefits: [
          "Native Performance",
          "Offline Functionality",
          "Biometric Security",
          "Cloud Sync",
          "Analytics Integration",
          "Regular Updates"
        ]
      },
      {
        id: 3,
        title: "Data Engineering",
        slug: "data-engineering",
        icon: "data",
        short_description: "Robust ETL systems and data engineering solutions for scale",
        description: "Transform your data into valuable insights with our comprehensive data engineering services. We build reliable data pipelines, warehouses, and processing systems that handle any scale.",
        features: [
          "ETL/ELT Pipelines",
          "Data Warehouse Design",
          "Real-time Data Processing",
          "Data Lake Architecture",
          "Stream Processing",
          "Data Quality & Governance"
        ],
        technologies: [ "Apache Spark", "Apache Kafka", "Airflow", "Snowflake", "Python", "SQL" ],
        process: [
          "Data Assessment",
          "Architecture Design",
          "Pipeline Development",
          "Data Validation",
          "Performance Tuning",
          "Monitoring & Alerts"
        ],
        benefits: [
          "Scalable Infrastructure",
          "Real-time Processing",
          "Data Quality Assurance",
          "Cost Optimization",
          "Automated Workflows",
          "Compliance Ready"
        ]
      },
      {
        id: 4,
        title: "Analytics Platforms",
        slug: "analytics-platforms",
        icon: "analytics",
        short_description: "Business intelligence and data visualization that drives decisions",
        description: "Make data-driven decisions with custom analytics platforms. We create intuitive dashboards, predictive models, and reporting systems that give you actionable insights.",
        features: [
          "Custom Dashboards",
          "Business Intelligence",
          "Predictive Analytics",
          "Machine Learning Models",
          "Real-time Reporting",
          "Data Visualization"
        ],
        technologies: [ "Tableau", "Power BI", "D3.js", "Python", "R", "TensorFlow" ],
        process: [
          "KPI Definition",
          "Data Integration",
          "Dashboard Design",
          "Model Development",
          "Testing & Validation",
          "Training & Support"
        ],
        benefits: [
          "Actionable Insights",
          "Automated Reporting",
          "Predictive Capabilities",
          "User-Friendly Interface",
          "Mobile Access",
          "Custom Metrics"
        ]
      },
      {
        id: 5,
        title: "Technical Consulting",
        slug: "technical-consulting",
        icon: "consulting",
        short_description: "Strategic technology guidance and architecture design",
        description: "Navigate complex technical decisions with confidence. Our experienced consultants help you choose the right technologies, design scalable architectures, and optimize your development processes.",
        features: [
          "Technology Strategy",
          "Architecture Review",
          "Code Audits",
          "Performance Optimization",
          "Security Assessment",
          "Team Training"
        ],
        technologies: [ "Cloud Platforms", "Microservices", "DevOps", "Security", "Agile", "Best Practices" ],
        process: [
          "Discovery & Assessment",
          "Gap Analysis",
          "Strategy Development",
          "Roadmap Creation",
          "Implementation Support",
          "Knowledge Transfer"
        ],
        benefits: [
          "Expert Guidance",
          "Risk Mitigation",
          "Cost Savings",
          "Best Practices",
          "Team Empowerment",
          "Strategic Alignment"
        ]
      }
    ]
  end

  def show
    # In a real application, this would fetch from database
    service_slug = params[:id]

    # Get all services (same as index)
    all_services = [
      {
        id: 1,
        title: "Web Development",
        slug: "web-development",
        icon: "web",
        short_description: "Custom web applications and SaaS platforms built with cutting-edge technologies",
        description: "We build scalable, secure, and high-performance web applications tailored to your business needs. From simple websites to complex SaaS platforms, we leverage modern frameworks and best practices to deliver exceptional digital experiences.",
        features: [
          "Custom Web Applications",
          "SaaS Platform Development",
          "E-commerce Solutions",
          "Progressive Web Apps (PWA)",
          "API Development & Integration",
          "Cloud Deployment & DevOps"
        ],
        technologies: [ "Ruby on Rails", "React", "Vue.js", "Node.js", "PostgreSQL", "AWS" ],
        process: [
          "Requirements Analysis",
          "UI/UX Design",
          "Agile Development",
          "Testing & QA",
          "Deployment",
          "Maintenance & Support"
        ],
        benefits: [
          "Scalable Architecture",
          "Security Best Practices",
          "Performance Optimization",
          "Mobile Responsive",
          "SEO Friendly",
          "24/7 Support"
        ]
      },
      {
        id: 2,
        title: "Mobile Development",
        slug: "mobile-development",
        icon: "mobile",
        short_description: "Native and cross-platform mobile apps that delight users",
        description: "Create engaging mobile experiences that your users will love. We develop native iOS and Android apps as well as cross-platform solutions that work seamlessly across all devices.",
        features: [
          "Native iOS Development",
          "Native Android Development",
          "Cross-platform Apps",
          "Mobile UI/UX Design",
          "App Store Optimization",
          "Push Notifications & Analytics"
        ],
        technologies: [ "Swift", "Kotlin", "React Native", "Flutter", "Firebase", "GraphQL" ],
        process: [
          "Concept & Strategy",
          "Wireframing & Prototyping",
          "Development & Testing",
          "App Store Submission",
          "Launch Support",
          "Updates & Maintenance"
        ],
        benefits: [
          "Native Performance",
          "Offline Functionality",
          "Biometric Security",
          "Cloud Sync",
          "Analytics Integration",
          "Regular Updates"
        ]
      },
      {
        id: 3,
        title: "Data Engineering",
        slug: "data-engineering",
        icon: "data",
        short_description: "Robust ETL systems and data engineering solutions for scale",
        description: "Transform your data into valuable insights with our comprehensive data engineering services. We build reliable data pipelines, warehouses, and processing systems that handle any scale.",
        features: [
          "ETL/ELT Pipelines",
          "Data Warehouse Design",
          "Real-time Data Processing",
          "Data Lake Architecture",
          "Stream Processing",
          "Data Quality & Governance"
        ],
        technologies: [ "Apache Spark", "Apache Kafka", "Airflow", "Snowflake", "Python", "SQL" ],
        process: [
          "Data Assessment",
          "Architecture Design",
          "Pipeline Development",
          "Data Validation",
          "Performance Tuning",
          "Monitoring & Alerts"
        ],
        benefits: [
          "Scalable Infrastructure",
          "Real-time Processing",
          "Data Quality Assurance",
          "Cost Optimization",
          "Automated Workflows",
          "Compliance Ready"
        ]
      },
      {
        id: 4,
        title: "Analytics Platforms",
        slug: "analytics-platforms",
        icon: "analytics",
        short_description: "Business intelligence and data visualization that drives decisions",
        description: "Make data-driven decisions with custom analytics platforms. We create intuitive dashboards, predictive models, and reporting systems that give you actionable insights.",
        features: [
          "Custom Dashboards",
          "Business Intelligence",
          "Predictive Analytics",
          "Machine Learning Models",
          "Real-time Reporting",
          "Data Visualization"
        ],
        technologies: [ "Tableau", "Power BI", "D3.js", "Python", "R", "TensorFlow" ],
        process: [
          "KPI Definition",
          "Data Integration",
          "Dashboard Design",
          "Model Development",
          "Testing & Validation",
          "Training & Support"
        ],
        benefits: [
          "Actionable Insights",
          "Automated Reporting",
          "Predictive Capabilities",
          "User-Friendly Interface",
          "Mobile Access",
          "Custom Metrics"
        ]
      },
      {
        id: 5,
        title: "Technical Consulting",
        slug: "technical-consulting",
        icon: "consulting",
        short_description: "Strategic technology guidance and architecture design",
        description: "Navigate complex technical decisions with confidence. Our experienced consultants help you choose the right technologies, design scalable architectures, and optimize your development processes.",
        features: [
          "Technology Strategy",
          "Architecture Review",
          "Code Audits",
          "Performance Optimization",
          "Security Assessment",
          "Team Training"
        ],
        technologies: [ "Cloud Platforms", "Microservices", "DevOps", "Security", "Agile", "Best Practices" ],
        process: [
          "Discovery & Assessment",
          "Gap Analysis",
          "Strategy Development",
          "Roadmap Creation",
          "Implementation Support",
          "Knowledge Transfer"
        ],
        benefits: [
          "Expert Guidance",
          "Risk Mitigation",
          "Cost Savings",
          "Best Practices",
          "Team Empowerment",
          "Strategic Alignment"
        ]
      }
    ]

    # Find the matching service
    @service = all_services.find { |s| s[:slug] == service_slug || s[:id].to_s == service_slug }

    # If service not found, redirect to services index
    unless @service
      redirect_to services_path, alert: "Service not found"
      nil
    end
  end
end
