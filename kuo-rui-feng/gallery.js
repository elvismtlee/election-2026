const viewer = document.querySelector('#viewer');
const photoLinks = [...document.querySelectorAll('.photo')];
const largePhoto = document.querySelector('#large-photo');
const caption = document.querySelector('#caption');
const count = document.querySelector('#photo-count');
let current = 0;

function showPhoto(index) {
  current = (index + photoLinks.length) % photoLinks.length;
  const link = photoLinks[current];
  largePhoto.src = link.href;
  largePhoto.alt = link.querySelector('img').alt;
  caption.textContent = largePhoto.alt;
  count.textContent = `${current + 1} / ${photoLinks.length}`;
}

if (typeof viewer.showModal === 'function') {
  photoLinks.forEach((link, index) => {
    link.addEventListener('click', event => {
      if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
      event.preventDefault();
      showPhoto(index);
      viewer.showModal();
    });
  });
  document.querySelector('#close-viewer').addEventListener('click', () => viewer.close());
  document.querySelector('#previous').addEventListener('click', () => showPhoto(current - 1));
  document.querySelector('#next').addEventListener('click', () => showPhoto(current + 1));
  viewer.addEventListener('keydown', event => {
    if (event.key === 'ArrowLeft') showPhoto(current - 1);
    if (event.key === 'ArrowRight') showPhoto(current + 1);
  });
  viewer.addEventListener('close', () => photoLinks[current].focus({ preventScroll: true }));
}

const videos = [...document.querySelectorAll('video')];
videos.forEach(video => {
  video.addEventListener('play', () => {
    videos.forEach(other => {
      if (other !== video && !other.paused) other.pause();
    });
  });
});

const actionStatus = document.querySelector('#action-status');
let statusTimeout;

async function copyText(text, successMessage) {
  try {
    await navigator.clipboard.writeText(text);
    actionStatus.textContent = successMessage;
  } catch {
    actionStatus.textContent = '無法存取剪貼簿，請手動複製或直接致電。';
  }
  actionStatus.hidden = false;
  clearTimeout(statusTimeout);
  statusTimeout = setTimeout(() => { actionStatus.hidden = true; }, 5000);
}

document.querySelectorAll('[data-copy]').forEach(button => {
  button.addEventListener('click', () => copyText(button.dataset.copy, '已複製到剪貼簿。'));
});

document.querySelector('#share-campaign').addEventListener('click', async () => {
  const url = new URL(location.pathname, location.origin).href;
  if (navigator.share) {
    try {
      await navigator.share({ title: document.title, url });
      return;
    } catch (error) {
      if (error.name === 'AbortError') return;
    }
  }
  await copyText(url, '已複製官網連結。');
});

document.querySelector('#service-report').addEventListener('submit', event => {
  event.preventDefault();
  const type = document.querySelector('#service-type').value;
  const detail = document.querySelector('#service-detail').value.trim();
  const report = [`保生里里務通報｜${type}`, detail].filter(Boolean).join('\n');
  copyText(report, '已複製通報內容，請貼到手機簡訊後自行送出。');
});
