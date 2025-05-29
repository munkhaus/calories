// Wiki JavaScript functionality

document.addEventListener('DOMContentLoaded', function() {
    initializeWiki();
});

function initializeWiki() {
    // Highlight current page in navigation
    highlightCurrentPage();
    
    // Initialize scroll to top button
    initScrollToTop();
    
    // Initialize code copy buttons
    initCodeCopyButtons();
    
    // Initialize table of contents
    initTableOfContents();
    
    // Initialize search functionality
    initSearch();
}

function highlightCurrentPage() {
    const currentPath = window.location.pathname.split('/').pop();
    const navLinks = document.querySelectorAll('.wiki-nav a');
    
    navLinks.forEach(link => {
        const linkPath = link.getAttribute('href');
        if (linkPath === currentPath || 
            (currentPath === '' && linkPath === 'index.html')) {
            link.classList.add('active');
        }
    });
}

function initScrollToTop() {
    // Create scroll to top button
    const scrollButton = document.createElement('button');
    scrollButton.className = 'scroll-top';
    scrollButton.innerHTML = '↑';
    scrollButton.style.display = 'none';
    document.body.appendChild(scrollButton);
    
    // Show/hide scroll button based on scroll position
    window.addEventListener('scroll', function() {
        if (window.pageYOffset > 300) {
            scrollButton.style.display = 'block';
        } else {
            scrollButton.style.display = 'none';
        }
    });
    
    // Scroll to top when clicked
    scrollButton.addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

function initCodeCopyButtons() {
    const codeBlocks = document.querySelectorAll('pre');
    
    codeBlocks.forEach(block => {
        const wrapper = document.createElement('div');
        wrapper.className = 'code-wrapper';
        wrapper.style.position = 'relative';
        
        block.parentNode.insertBefore(wrapper, block);
        wrapper.appendChild(block);
        
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-btn';
        copyButton.innerHTML = '📋 Copy';
        copyButton.style.cssText = `
            position: absolute;
            top: 0.5rem;
            right: 0.5rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            cursor: pointer;
            font-size: 0.75rem;
            transition: all 0.2s ease;
        `;
        
        copyButton.addEventListener('click', function() {
            const code = block.querySelector('code');
            const text = code ? code.textContent : block.textContent;
            
            navigator.clipboard.writeText(text).then(function() {
                copyButton.innerHTML = '✅ Copied!';
                setTimeout(() => {
                    copyButton.innerHTML = '📋 Copy';
                }, 2000);
            });
        });
        
        wrapper.appendChild(copyButton);
    });
}

function initTableOfContents() {
    const content = document.querySelector('.wiki-content');
    if (!content) return;
    
    const headings = content.querySelectorAll('h2, h3, h4');
    if (headings.length === 0) return;
    
    const toc = document.createElement('div');
    toc.className = 'table-of-contents';
    toc.innerHTML = '<h4>Indholdsfortegnelse</h4>';
    
    const tocList = document.createElement('ul');
    toc.appendChild(tocList);
    
    headings.forEach((heading, index) => {
        const id = `heading-${index}`;
        heading.id = id;
        
        const li = document.createElement('li');
        li.className = `toc-${heading.tagName.toLowerCase()}`;
        
        const link = document.createElement('a');
        link.href = `#${id}`;
        link.textContent = heading.textContent;
        link.addEventListener('click', function(e) {
            e.preventDefault();
            heading.scrollIntoView({ behavior: 'smooth' });
        });
        
        li.appendChild(link);
        tocList.appendChild(li);
    });
    
    // Insert TOC after the first heading or at the beginning
    const firstHeading = content.querySelector('h1, h2');
    if (firstHeading) {
        firstHeading.parentNode.insertBefore(toc, firstHeading.nextSibling);
    } else {
        content.insertBefore(toc, content.firstChild);
    }
}

function initSearch() {
    // This is a basic search implementation
    // For a more advanced search, consider using a library like Lunr.js
    
    const searchInput = document.createElement('input');
    searchInput.type = 'search';
    searchInput.placeholder = 'Søg i dokumentation...';
    searchInput.className = 'wiki-search';
    searchInput.style.cssText = `
        width: 100%;
        padding: 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        margin-bottom: 1rem;
        font-size: 0.875rem;
    `;
    
    const sidebar = document.querySelector('.wiki-sidebar');
    if (sidebar) {
        const nav = sidebar.querySelector('.wiki-nav');
        sidebar.insertBefore(searchInput, nav);
        
        searchInput.addEventListener('input', function() {
            const query = this.value.toLowerCase();
            const navItems = document.querySelectorAll('.wiki-nav a');
            
            navItems.forEach(item => {
                const text = item.textContent.toLowerCase();
                const listItem = item.parentNode;
                
                if (text.includes(query) || query === '') {
                    listItem.style.display = 'block';
                } else {
                    listItem.style.display = 'none';
                }
            });
        });
    }
}

// Utility functions
function createInfoBox(type, content) {
    const box = document.createElement('div');
    box.className = `info-box ${type}`;
    box.innerHTML = content;
    return box;
}

function createCard(title, content) {
    const card = document.createElement('div');
    card.className = 'wiki-card';
    card.innerHTML = `
        <h3>${title}</h3>
        ${content}
    `;
    return card;
} 