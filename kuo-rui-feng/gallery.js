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
