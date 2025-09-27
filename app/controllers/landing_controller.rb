class LandingController < ApplicationController
  def index
    @services = [
      {
        title: "Web Development",
        description: "Custom web applications and SaaS platforms built with cutting-edge technologies",
        icon: "web",
        features: ["React/Vue.js", "Ruby on Rails", "API Development", "Cloud Deployment"]
      },
      {
        title: "Mobile Applications",
        description: "Native and cross-platform mobile apps that delight users",
        icon: "mobile",
        features: ["iOS Development", "Android Apps", "React Native", "Flutter"]
      },
      {
        title: "Data Pipelines",
        description: "Robust ETL systems and data engineering solutions for scale",
        icon: "data",
        features: ["ETL Systems", "Real-time Processing", "Data Warehousing", "Apache Spark"]
      },
      {
        title: "Analytics Platforms",
        description: "Business intelligence and data visualization that drives decisions",
        icon: "analytics",
        features: ["Custom Dashboards", "Predictive Analytics", "ML Integration", "Real-time Insights"]
      }
    ]

    @stats = [
      { value: "150+", label: "Projects Delivered", icon: "projects" },
      { value: "98%", label: "Client Satisfaction", icon: "satisfaction" },
      { value: "3x", label: "Average ROI", icon: "roi" },
      { value: "50+", label: "Team Members", icon: "team" }
    ]

    @testimonials = [
      {
        content: "KojAgency transformed our digital presence. Their expertise in both development and data analytics gave us insights we never had before.",
        author: "Sarah Chen",
        position: "CEO, TechVentures",
        company_logo: "techventures",
        rating: 5
      },
      {
        content: "The data pipeline they built processes millions of events daily without a hiccup. Truly impressive engineering.",
        author: "Michael Rodriguez",
        position: "CTO, DataFlow Inc",
        company_logo: "dataflow",
        rating: 5
      },
      {
        content: "From concept to launch in 12 weeks. The mobile app they delivered exceeded all our expectations.",
        author: "Emily Watson",
        position: "Product Manager, InnovateCo",
        company_logo: "innovateco",
        rating: 5
      }
    ]

    @portfolio_items = [
      {
        title: "E-Commerce Platform",
        category: "web",
        client: "RetailPlus",
        description: "Scalable marketplace handling 1M+ transactions monthly",
        metrics: { revenue: "+240%", users: "500K+", performance: "99.9%" }
      },
      {
        title: "Analytics Dashboard",
        category: "analytics",
        client: "FinanceHub",
        description: "Real-time financial analytics for 10,000+ traders",
        metrics: { processing: "50K/sec", uptime: "99.99%", roi: "5x" }
      },
      {
        title: "Mobile Banking App",
        category: "mobile",
        client: "NextBank",
        description: "Secure banking app with biometric authentication",
        metrics: { downloads: "2M+", rating: "4.8★", transactions: "$1B+" }
      },
      {
        title: "Data Processing Pipeline",
        category: "data",
        client: "LogiTech",
        description: "Real-time IoT data processing at scale",
        metrics: { events: "10M/day", latency: "<100ms", cost: "-60%" }
      }
    ]

    @process_steps = [
      {
        number: "01",
        title: "Discovery",
        description: "We dive deep into your business goals and technical requirements"
      },
      {
        number: "02",
        title: "Strategy",
        description: "Craft a tailored solution architecture and project roadmap"
      },
      {
        number: "03",
        title: "Development",
        description: "Agile development with continuous testing and feedback loops"
      },
      {
        number: "04",
        title: "Launch & Scale",
        description: "Deploy, monitor, and continuously improve your solution"
      }
    ]
  end

  def about
    @team_members = [
      {
        name: "John Smith",
        role: "CEO & Founder",
        bio: "15+ years in tech leadership and digital transformation",
        image: "team1"
      },
      {
        name: "Sarah Johnson",
        role: "CTO",
        bio: "Expert in scalable architectures and cloud solutions",
        image: "team2"
      },
      {
        name: "Michael Chen",
        role: "Head of Design",
        bio: "Award-winning designer with focus on user experience",
        image: "team3"
      },
      {
        name: "Emily Davis",
        role: "Lead Developer",
        bio: "Full-stack developer specializing in modern web technologies",
        image: "team4"
      }
    ]

    @values = [
      {
        title: "Innovation",
        description: "Pushing boundaries with cutting-edge technology"
      },
      {
        title: "Quality",
        description: "Delivering excellence in every line of code"
      },
      {
        title: "Partnership",
        description: "Building long-term relationships with our clients"
      },
      {
        title: "Impact",
        description: "Creating solutions that drive real business value"
      }
    ]
  end

  def contact
    @contact_info = {
      email: "hello@kojagency.com",
      phone: "+1 (234) 567-890",
      address: "123 Tech Street, San Francisco, CA 94105",
      hours: "Monday - Friday, 9:00 AM - 6:00 PM PST"
    }
  end
end