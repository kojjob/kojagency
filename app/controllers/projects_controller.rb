class ProjectsController < ApplicationController
  def index
    @projects = [
      {
        id: 1,
        title: "E-Commerce Platform Redesign",
        client: "RetailPlus",
        category: "Web Development",
        description: "Complete redesign and rebuild of a high-traffic e-commerce platform handling millions in monthly transactions.",
        technologies: ["Ruby on Rails", "React", "PostgreSQL", "Redis", "AWS"],
        results: {
          revenue: "+240% increase",
          conversion: "+85% improvement",
          performance: "60% faster load times"
        },
        testimonial: "KojAgency transformed our online presence. The new platform is faster, more reliable, and our customers love it.",
        image: "project1"
      },
      {
        id: 2,
        title: "Real-time Analytics Dashboard",
        client: "DataFlow Inc",
        category: "Analytics Platform",
        description: "Custom analytics platform processing millions of events daily with real-time visualization and insights.",
        technologies: ["Python", "Apache Spark", "Elasticsearch", "React", "D3.js"],
        results: {
          processing: "10M events/day",
          latency: "<100ms response time",
          savings: "60% cost reduction"
        },
        testimonial: "The analytics platform exceeded all expectations. We now have insights we never thought possible.",
        image: "project2"
      },
      {
        id: 3,
        title: "Mobile Banking Application",
        client: "NextBank",
        category: "Mobile Development",
        description: "Secure, user-friendly mobile banking app with biometric authentication and real-time transactions.",
        technologies: ["React Native", "Node.js", "MongoDB", "AWS", "Plaid API"],
        results: {
          users: "2M+ downloads",
          rating: "4.8★ app store rating",
          transactions: "$1B+ processed"
        },
        testimonial: "The app has revolutionized how our customers interact with their finances. Outstanding work!",
        image: "project3"
      },
      {
        id: 4,
        title: "IoT Data Pipeline",
        client: "SmartHome Corp",
        category: "Data Engineering",
        description: "Scalable data pipeline processing IoT sensor data from millions of connected devices.",
        technologies: ["Apache Kafka", "Apache Flink", "Cassandra", "Python", "Kubernetes"],
        results: {
          scale: "5M devices connected",
          throughput: "100K messages/sec",
          uptime: "99.99% availability"
        },
        testimonial: "The data pipeline handles our massive IoT infrastructure flawlessly. Incredible engineering!",
        image: "project4"
      }
    ]

    @categories = ["All", "Web Development", "Mobile Development", "Data Engineering", "Analytics Platform"]
  end

  def show
    # In a real application, this would fetch from database
    @project = {
      id: params[:id],
      title: "E-Commerce Platform Redesign",
      client: "RetailPlus",
      category: "Web Development",
      year: "2024",
      duration: "6 months",
      team_size: "8 members",
      description: "Complete redesign and rebuild of a high-traffic e-commerce platform. The project involved modernizing the tech stack, implementing a microservices architecture, and creating a seamless omnichannel experience.",
      challenge: "The existing platform was built on legacy technology that couldn't handle peak traffic loads, resulting in lost sales and poor customer experience. The system needed to be rebuilt without disrupting ongoing operations.",
      solution: "We implemented a phased migration strategy, building the new platform in parallel with the existing one. Using modern cloud-native technologies and a microservices architecture, we created a scalable solution that could handle 10x the previous traffic.",
      technologies: ["Ruby on Rails", "React", "PostgreSQL", "Redis", "AWS", "Docker", "Kubernetes"],
      features: [
        "Real-time inventory management",
        "AI-powered product recommendations",
        "One-click checkout process",
        "Multi-currency support",
        "Advanced search and filtering",
        "Mobile-first responsive design"
      ],
      results: {
        revenue: "+240% increase in revenue",
        conversion: "+85% improvement in conversion rate",
        performance: "60% faster page load times",
        uptime: "99.99% uptime achieved",
        satisfaction: "4.9/5 customer satisfaction"
      },
      testimonial: {
        content: "Working with KojAgency was a game-changer for our business. They not only delivered a stunning new platform but also helped us streamline our operations and significantly boost our revenue. The team's expertise in both technology and business strategy was invaluable.",
        author: "Michael Chen",
        position: "CEO, RetailPlus"
      },
      images: ["project1", "project1-2", "project1-3"]
    }
  end
end