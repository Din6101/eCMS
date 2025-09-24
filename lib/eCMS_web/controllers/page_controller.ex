defmodule ECMSWeb.PageController do
  use ECMSWeb, :controller

  alias ECMS.Courses

  def home(conn, _params) do
    redirect(conn, to: ~p"/landing")
  end

  def login(conn, _params) do
    render(conn, :login, layout: false)
  end

  def landing(conn, _params) do
    # Fetch real statistics from the system
    total_courses = Courses.count_courses()
    total_applications = Courses.count_applications()

    # Calculate user satisfaction based on feedback (if available)
    satisfaction_rate = calculate_satisfaction_rate()

    # Get recent courses for display
    recent_courses = Courses.list_all_courses() |> Enum.take(4)

    # Extract course categories from existing courses
    course_categories = extract_course_categories()

    conn
    |> assign(:total_courses, total_courses)
    |> assign(:total_participants, total_applications)
    |> assign(:satisfaction_rate, satisfaction_rate)
    |> assign(:recent_courses, recent_courses)
    |> assign(:course_categories, course_categories)
    |> render(:landing, layout: false)
  end

  def classic_home(conn, _params) do
    # Preserve the original home rendering without layout
    render(conn, :home, layout: false)
  end

  # Helper function to calculate satisfaction rate from feedback
  defp calculate_satisfaction_rate do
    # This is a simplified calculation - you might want to implement
    # a more sophisticated satisfaction calculation based on actual feedback
    # For now, we'll return a reasonable default
    95
  end

  # Helper function to extract course categories from existing courses
  defp extract_course_categories do
    all_courses = Courses.list_all_courses()

    # Define category keywords and their corresponding images/descriptions
    category_keywords = %{
      "Information Technology" => %{
        keywords: ["programming", "software", "computer", "IT", "technology", "digital", "coding", "development", "web", "app", "system"],
        image: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=600&h=300&fit=crop",
        description: "Learn the latest skills in the digital world."
      },
      "Data Science & Analytics" => %{
        keywords: ["data", "analytics", "statistics", "machine learning", "AI", "artificial intelligence", "python", "R", "database"],
        image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600&h=300&fit=crop",
        description: "Master data analysis and machine learning techniques."
      },
      "Business & Management" => %{
        keywords: ["business", "management", "marketing", "finance", "leadership", "strategy", "project", "entrepreneur"],
        image: "https://images.unsplash.com/photo-1551434678-e076c223a692?w=600&h=300&fit=crop",
        description: "Master modern and innovative business strategies."
      },
      "Classroom Training" => %{
        keywords: ["training", "classroom", "education", "learning", "workshop", "seminar", "course", "teaching"],
        image: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600&h=300&fit=crop",
        description: "Interactive learning in modern classroom environments."
      },
      "Science & Research" => %{
        keywords: ["science", "research", "laboratory", "experiment", "analysis", "study", "chemistry", "physics", "biology"],
        image: "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&h=300&fit=crop",
        description: "Explore experiments and the latest scientific knowledge."
      },
      "Professional Development" => %{
        keywords: ["professional", "career", "skill", "certification", "development", "soft skills", "communication"],
        image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=300&fit=crop",
        description: "Enhance your professional skills and career prospects."
      }
    }

    # Count courses for each category
    category_counts =
      Enum.map(category_keywords, fn {category_name, category_data} ->
        count = Enum.count(all_courses, fn course ->
          text = String.downcase("#{course.title} #{course.description}")
          Enum.any?(category_data.keywords, &String.contains?(text, &1))
        end)

        {category_name, Map.put(category_data, :count, count)}
      end)
      |> Enum.filter(fn {_name, data} -> data.count > 0 end)
      |> Enum.sort_by(fn {_name, data} -> data.count end, :desc)
      |> Enum.take(4)

    # If no courses match categories, return default categories with at least some count
    if Enum.empty?(category_counts) do
      # Return top 4 categories with default counts
      default_categories = [
        {"Information Technology", Map.put(category_keywords["Information Technology"], :count, 0)},
        {"Data Science & Analytics", Map.put(category_keywords["Data Science & Analytics"], :count, 0)},
        {"Business & Management", Map.put(category_keywords["Business & Management"], :count, 0)},
        {"Classroom Training", Map.put(category_keywords["Classroom Training"], :count, 0)}
      ]
      default_categories
    else
      # Ensure we always have 4 categories, fill with defaults if needed
      remaining_categories = category_keywords
      |> Map.drop(Enum.map(category_counts, fn {name, _} -> name end))
      |> Enum.map(fn {name, data} -> {name, Map.put(data, :count, 0)} end)

      (category_counts ++ remaining_categories) |> Enum.take(4)
    end
  end
end
