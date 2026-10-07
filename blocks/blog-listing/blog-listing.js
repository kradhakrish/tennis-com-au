const dateFormat = new Intl.DateTimeFormat('en-AU', {
  day: 'numeric',
  month: 'long',
  year: 'numeric',
  timeZone: 'Australia/Melbourne',
});

function buildCard(row) {
  const [titleCell, dateCell, summaryCell] = [...row.children];
  const link = titleCell?.querySelector('a');
  if (!link) return null;

  const li = document.createElement('li');
  const article = document.createElement('article');
  article.className = 'blog-listing-card';

  const iso = dateCell?.textContent.trim();
  const date = iso ? new Date(iso) : null;
  const hasDate = date && !Number.isNaN(date.getTime());
  li.dataset.sort = hasDate ? date.getTime() : 0;
  if (hasDate) {
    const time = document.createElement('time');
    time.dateTime = iso;
    time.textContent = dateFormat.format(date);
    article.append(time);
  }

  const heading = document.createElement('h2');
  const titleLink = document.createElement('a');
  titleLink.href = link.href;
  titleLink.textContent = link.textContent.trim();
  heading.append(titleLink);
  article.append(heading);

  if (summaryCell && summaryCell.textContent.trim()) {
    const summary = document.createElement('div');
    summary.className = 'blog-listing-summary';
    summary.append(...summaryCell.childNodes);
    article.append(summary);
  }

  const more = document.createElement('span');
  more.className = 'blog-listing-more';
  more.setAttribute('aria-hidden', 'true');
  more.textContent = 'Read article';
  article.append(more);

  li.append(article);
  return li;
}

/**
 * Renders the article list produced by the json2html blog-listing template.
 * Each row: title link | ISO publish date | summary.
 * @param {Element} block The block element
 */
export default function decorate(block) {
  const items = [...block.children]
    .map(buildCard)
    .filter(Boolean)
    .sort((a, b) => b.dataset.sort - a.dataset.sort);

  const ul = document.createElement('ul');
  ul.append(...items);
  block.replaceChildren(ul);
}
