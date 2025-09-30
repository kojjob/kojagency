// Reading Progress Bar
document.addEventListener('DOMContentLoaded', function() {
  const progressBar = document.getElementById('reading-progress');

  if (progressBar) {
    window.addEventListener('scroll', function() {
      const article = document.querySelector('article');
      if (!article) return;

      const articleHeight = article.offsetHeight;
      const windowHeight = window.innerHeight;
      const scrolled = window.pageYOffset;
      const articleTop = article.offsetTop;
      const articleBottom = articleTop + articleHeight;

      let progress = 0;
      if (scrolled > articleTop) {
        if (scrolled < articleBottom - windowHeight) {
          progress = ((scrolled - articleTop) / (articleHeight - windowHeight)) * 100;
        } else {
          progress = 100;
        }
      }

      progressBar.style.width = `${Math.min(Math.max(progress, 0), 100)}%`;
    });
  }

  // Table of Contents Generation
  const tocList = document.getElementById('toc-list');
  const articleContent = document.querySelector('.article-content');

  if (tocList && articleContent) {
    const headings = articleContent.querySelectorAll('h2, h3');

    headings.forEach((heading, index) => {
      // Add ID to heading for anchor link
      if (!heading.id) {
        heading.id = `heading-${index}`;
      }

      // Create TOC item
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.href = `#${heading.id}`;
      a.textContent = heading.textContent;
      a.className = heading.tagName === 'H2'
        ? 'block py-1 text-gray-700 hover:text-indigo-600 transition-colors'
        : 'block py-1 pl-4 text-gray-600 hover:text-indigo-600 transition-colors text-sm';

      // Smooth scroll
      a.addEventListener('click', function(e) {
        e.preventDefault();
        heading.scrollIntoView({ behavior: 'smooth', block: 'start' });

        // Update URL without jumping
        history.pushState(null, null, `#${heading.id}`);
      });

      li.appendChild(a);
      tocList.appendChild(li);
    });

    // Highlight active section in TOC
    const observerOptions = {
      rootMargin: '-100px 0px -80% 0px',
      threshold: 0
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        const tocLink = tocList.querySelector(`a[href="#${entry.target.id}"]`);
        if (tocLink) {
          if (entry.isIntersecting) {
            // Remove all active classes
            tocList.querySelectorAll('a').forEach(a => {
              a.classList.remove('text-indigo-600', 'font-semibold');
              a.classList.add('text-gray-700');
            });
            // Add active class to current
            tocLink.classList.remove('text-gray-700');
            tocLink.classList.add('text-indigo-600', 'font-semibold');
          }
        }
      });
    }, observerOptions);

    headings.forEach(heading => observer.observe(heading));
  }

  // Parallax Effect for Hero Image
  const parallaxImg = document.querySelector('.parallax-img');
  if (parallaxImg) {
    window.addEventListener('scroll', function() {
      const scrolled = window.pageYOffset;
      const parallaxSpeed = 0.5;
      parallaxImg.style.transform = `translateY(${scrolled * parallaxSpeed}px)`;
    });
  }

  // Text Selection Sharing (Optional Enhancement)
  document.addEventListener('mouseup', function(e) {
    const selection = window.getSelection().toString().trim();
    if (selection.length > 10 && selection.length < 280) {
      // Could implement a share tooltip here
      console.log('Selected text:', selection);
    }
  });
});