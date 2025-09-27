class LeadScoringService
  # Scoring weights based on business requirements
  BUDGET_WEIGHT = 0.35      # 35% - Budget is most important
  TIMELINE_WEIGHT = 0.25    # 25% - Timeline urgency
  COMPLEXITY_WEIGHT = 0.20  # 20% - Project complexity
  QUALITY_WEIGHT = 0.20     # 20% - Lead quality indicators

  attr_reader :lead, :budget_score, :timeline_score, :complexity_score, :quality_score

  def initialize(lead)
    @lead = lead
    @budget_score = 0.0
    @timeline_score = 0.0
    @complexity_score = 0.0
    @quality_score = 0.0
  end

  def calculate_total_score
    @budget_score = calculate_budget_score
    @timeline_score = calculate_timeline_score
    @complexity_score = calculate_complexity_score
    @quality_score = calculate_quality_score

    total = (@budget_score * BUDGET_WEIGHT) +
            (@timeline_score * TIMELINE_WEIGHT) +
            (@complexity_score * COMPLEXITY_WEIGHT) +
            (@quality_score * QUALITY_WEIGHT)

    total.round(2)
  end

  private

  def calculate_budget_score
    case lead.budget
    when '250k_plus'
      100.0
    when '100k_250k'
      85.0
    when '50k_100k'
      70.0
    when '25k_50k'
      55.0
    when '10k_25k'
      35.0
    when 'under_10k'
      15.0
    else
      0.0
    end
  end

  def calculate_timeline_score
    case lead.timeline
    when 'asap'
      100.0
    when '1_month'
      85.0
    when '3_months'
      70.0
    when '6_months'
      50.0
    when '1_year'
      30.0
    when 'flexible'
      20.0
    else
      0.0
    end
  end

  def calculate_complexity_score
    base_score = case lead.project_type
    when 'data_engineering'
      100.0  # Highest complexity, highest value
    when 'analytics_platform'
      90.0   # High complexity, custom solutions
    when 'technical_consulting'
      85.0   # Strategic, high-value engagements
    when 'web_development'
      70.0   # Medium complexity, good margins
    when 'mobile_development'
      75.0   # Medium-high complexity
    when 'other'
      50.0   # Unknown complexity
    else
      50.0
    end

    # Adjust based on project description complexity indicators
    description_bonus = analyze_description_complexity
    [base_score + description_bonus, 100.0].min
  end

  def calculate_quality_score
    score = 0.0

    # Company name provided (indicates seriousness)
    score += 20.0 if lead.company.present? && lead.company.strip.length > 2

    # Phone number provided (higher engagement likelihood)
    score += 15.0 if lead.phone.present?

    # Website provided (established business)
    score += 10.0 if lead.website.present?

    # Professional email domain (not gmail, yahoo, etc.)
    score += 15.0 if professional_email_domain?

    # Detailed project description
    score += 20.0 if detailed_description?

    # Contact preference indicates engagement level
    score += 10.0 if lead.preferred_contact_method == 'both'
    score += 5.0 if lead.preferred_contact_method == 'phone'

    # Source quality (referrals are highest quality)
    score += source_quality_bonus

    [score, 100.0].min
  end

  def analyze_description_complexity
    return 0.0 if lead.project_description.blank?

    description = lead.project_description.downcase
    bonus = 0.0

    # Technical complexity indicators
    complex_terms = [
      'api', 'integration', 'machine learning', 'ai', 'automation',
      'microservices', 'cloud', 'aws', 'azure', 'gcp', 'kubernetes',
      'real-time', 'scalability', 'performance', 'security',
      'compliance', 'analytics', 'dashboard', 'reporting',
      'database', 'data warehouse', 'etl', 'pipeline'
    ]

    technical_mentions = complex_terms.count { |term| description.include?(term) }
    bonus += [technical_mentions * 3, 15].min

    # Urgency indicators
    urgent_terms = ['urgent', 'asap', 'immediately', 'critical', 'priority']
    urgent_mentions = urgent_terms.count { |term| description.include?(term) }
    bonus += [urgent_mentions * 2, 8].min

    # Scale indicators
    scale_terms = ['enterprise', 'large scale', 'million', 'thousand users', 'global']
    scale_mentions = scale_terms.count { |term| description.include?(term) }
    bonus += [scale_mentions * 4, 12].min

    bonus
  end

  def professional_email_domain?
    return false if lead.email.blank?

    email_domain = lead.email.split('@').last&.downcase
    return false if email_domain.blank?

    # Common personal email domains
    personal_domains = %w[
      gmail.com yahoo.com hotmail.com outlook.com aol.com
      icloud.com me.com live.com msn.com
    ]

    !personal_domains.include?(email_domain)
  end

  def detailed_description?
    return false if lead.project_description.blank?

    description = lead.project_description.strip
    word_count = description.split.length

    # Consider detailed if more than 30 words and contains specific details
    word_count >= 30 && contains_specific_details?
  end

  def contains_specific_details?
    description = lead.project_description.downcase

    # Look for specific requirements, features, or technical details
    detail_indicators = [
      'requirement', 'feature', 'functionality', 'user', 'system',
      'platform', 'technology', 'framework', 'tool', 'integrate',
      'connect', 'sync', 'automate', 'custom', 'specific'
    ]

    detail_indicators.any? { |indicator| description.include?(indicator) }
  end

  def source_quality_bonus
    case lead.source
    when 'referral'
      15.0
    when 'linkedin'
      10.0
    when 'google_organic'
      8.0
    when 'direct'
      5.0
    when 'social_media'
      3.0
    when 'website'
      0.0
    else
      0.0
    end
  end
end