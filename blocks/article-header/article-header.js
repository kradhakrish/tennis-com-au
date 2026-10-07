const dateFormat = new Intl.DateTimeFormat('en-AU', {
  day: 'numeric',
  month: 'long',
  year: 'numeric',
  timeZone: 'Australia/Melbourne',
});

function buildBreadcrumbs(row) {
  const links = [...row.querySelectorAll('a')];
  if (!links.length) return null;

  const nav = document.createElement('nav');
  nav.setAttribute('aria-label', 'Breadcrumb');
  const ol = document.createElement('ol');
  links.forEach((link) => {
    const li = document.createElement('li');
    const a = document.createElement('a');
    a.href = link.href;
    a.textContent = link.textContent.trim();
    li.append(a);
    ol.append(li);
  });
  nav.append(ol);
  return nav;
}

/**
 * Renders the header of a json2html blog article page.
 * Rows: breadcrumb links | title and subtitle | ISO publish date.
 * @param {Element} block The block element
 */
export default function decorate(block) {
  const [crumbRow, titleRow, dateRow] = [...block.children];
  const content = [];

  const nav = crumbRow && buildBreadcrumbs(crumbRow);
  if (nav) content.push(nav);

  const title = titleRow?.querySelector('h1');
  if (title) {
    content.push(title);
    const lead = document.createElement('div');
    lead.className = 'article-header-lead';
    lead.append(...titleRow.querySelectorAll('p'));
    if (lead.children.length) content.push(lead);
  }

  const iso = dateRow?.textContent.trim();
  const date = iso ? new Date(iso) : null;
  if (date && !Number.isNaN(date.getTime())) {
    const p = document.createElement('p');
    p.className = 'article-header-date';
    const time = document.createElement('time');
    time.dateTime = iso;
    time.textContent = dateFormat.format(date);
    p.append('Published ', time);
    content.push(p);
  }

  block.replaceChildren(...content);
}
