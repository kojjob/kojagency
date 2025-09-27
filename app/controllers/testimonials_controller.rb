class TestimonialsController < ApplicationController
  def index
    @testimonials = [
      {
        id: 1,
        content: "KojAgency transformed our digital presence. Their expertise in both development and data analytics gave us insights we never had before. The team was professional, responsive, and delivered beyond our expectations.",
        author: "Sarah Chen",
        position: "CEO",
        company: "TechVentures Inc",
        rating: 5,
        project: "E-Commerce Platform",
        date: "March 2024"
      },
      {
        id: 2,
        content: "The data pipeline they built processes millions of events daily without a hiccup. Truly impressive engineering. We've reduced our data processing costs by 60% while improving reliability.",
        author: "Michael Rodriguez",
        position: "CTO",
        company: "DataFlow Inc",
        rating: 5,
        project: "Analytics Platform",
        date: "February 2024"
      },
      {
        id: 3,
        content: "From concept to launch in 12 weeks. The mobile app they delivered exceeded all our expectations. Our users love the intuitive design and smooth performance.",
        author: "Emily Watson",
        position: "Product Manager",
        company: "InnovateCo",
        rating: 5,
        project: "Mobile Banking App",
        date: "January 2024"
      },
      {
        id: 4,
        content: "Working with KojAgency was a game-changer. They didn't just build software; they became our technology partners, helping us make strategic decisions that accelerated our growth.",
        author: "David Park",
        position: "Founder",
        company: "StartupHub",
        rating: 5,
        project: "SaaS Platform",
        date: "December 2023"
      },
      {
        id: 5,
        content: "The analytics dashboard they created gives us real-time insights into our business. It's become an essential tool for our decision-making process.",
        author: "Lisa Thompson",
        position: "VP of Operations",
        company: "RetailPlus",
        rating: 5,
        project: "Business Intelligence",
        date: "November 2023"
      }
    ]
  end
end