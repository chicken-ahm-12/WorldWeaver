const navLinks=[...document.querySelectorAll('#nav a')];
const sections=[...document.querySelectorAll('.section-anchor[id]')];
const observer=new IntersectionObserver(entries=>{entries.forEach(e=>{if(e.isIntersecting){navLinks.forEach(a=>a.classList.toggle('active',a.getAttribute('href')==='#'+e.target.id));}})},{rootMargin:'-25% 0px -65% 0px',threshold:0});
sections.forEach(s=>observer.observe(s));
const settingSearch=document.getElementById('settingSearch');
const rows=[...document.querySelectorAll('.setting-row:not(.head)')];
const chips=[...document.querySelectorAll('.chip')]; let activeGroup='all';
function filter(){const q=settingSearch.value.trim().toLowerCase();rows.forEach(r=>{const text=r.innerText.toLowerCase();const okGroup=activeGroup==='all'||r.dataset.group===activeGroup; r.classList.toggle('hidden',!(okGroup&&text.includes(q)));});}
settingSearch.addEventListener('input',filter);chips.forEach(c=>c.addEventListener('click',()=>{chips.forEach(x=>x.classList.remove('active'));c.classList.add('active');activeGroup=c.dataset.group;filter();}));
const modal=document.getElementById('searchModal'), globalSearch=document.getElementById('globalSearch'), results=document.getElementById('searchResults');
const docs=[...document.querySelectorAll('main section[id]')].map(s=>({id:s.id,title:s.querySelector('h2,h1')?.innerText||s.id,text:s.innerText.replace(/\s+/g,' ').slice(0,220)}));
function openSearch(){modal.classList.add('open');modal.setAttribute('aria-hidden','false');setTimeout(()=>globalSearch.focus(),20);renderResults('');}
function closeSearch(){modal.classList.remove('open');modal.setAttribute('aria-hidden','true');}
function renderResults(q){const needle=q.toLowerCase().trim();const matches=docs.filter(d=>!needle||(`${d.title} ${d.text}`).toLowerCase().includes(needle)).slice(0,8);results.innerHTML=matches.map(d=>`<a class="result" href="#${d.id}"><b>${d.title}</b><span>${d.text}</span></a>`).join('')||'<div class="result"><b>No matches</b><span>Try a different setting, concept or section name.</span></div>';results.querySelectorAll('a').forEach(a=>a.addEventListener('click',closeSearch));}
document.getElementById('searchButton').addEventListener('click',openSearch);document.getElementById('closeSearch').addEventListener('click',closeSearch);globalSearch.addEventListener('input',e=>renderResults(e.target.value));modal.addEventListener('click',e=>{if(e.target===modal)closeSearch()});document.addEventListener('keydown',e=>{if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='k'){e.preventDefault();openSearch()}if(e.key==='Escape')closeSearch()});
