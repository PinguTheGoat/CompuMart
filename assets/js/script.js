var Menuitems = document.getElementById("Menuitems");

if (Menuitems) {
    Menuitems.style.maxHeight = "0px";
}

function menutoggle() {
    if (Menuitems) {
        if (Menuitems.style.maxHeight == "0px") {
            Menuitems.style.maxHeight = "200px";
        } else {
            Menuitems.style.maxHeight = "0px";
        }
    }
}

class SeamlessCarousel {
    constructor(root) {
        this.root = root;
        this.track = root.querySelector('[data-track]');
        this.prevBtn = root.querySelector('[data-prev]');
        this.nextBtn = root.querySelector('[data-next]');
        this.origSlides = Array.from(this.track.children);
        this.originalCount = this.origSlides.length;
        this.currentIndex = this.originalCount;
        this.step = 0;
        this.isAnimating = false;
        this.handleTransitionEnd = this.handleTransitionEnd.bind(this);
        this.handleResize = this.handleResize.bind(this);
        this.init();
    }

    init() {
        if (this.originalCount === 0) return;

        const beforeClones = this.origSlides.map((slide) => slide.cloneNode(true));
        const afterClones = this.origSlides.map((slide) => slide.cloneNode(true));

        beforeClones.reverse().forEach((clone) => {
            this.track.insertBefore(clone, this.track.firstChild);
        });
        afterClones.forEach((clone) => this.track.appendChild(clone));

        this.allSlides = Array.from(this.track.children);
        this.track.style.willChange = 'transform';

        requestAnimationFrame(() => {
            this.setStep();
            this.jumpTo(this.currentIndex, false);
        });

        this.prevBtn?.addEventListener('click', () => this.move(-1));
        this.nextBtn?.addEventListener('click', () => this.move(1));
        this.track.addEventListener('transitionend', this.handleTransitionEnd);
        window.addEventListener('resize', this.handleResize);
    }

    setStep() {
        if (this.allSlides.length < 2) {
            this.step = this.allSlides[0].getBoundingClientRect().width;
            return;
        }

        const first = this.allSlides[0].getBoundingClientRect();
        const second = this.allSlides[1].getBoundingClientRect();
        this.step = Math.abs(second.left - first.left);
    }

    move(direction) {
        if (this.isAnimating) return;
        this.isAnimating = true;
        this.currentIndex += direction;
        this.track.style.transition = 'transform 0.45s cubic-bezier(0.22, 0.61, 0.36, 1)';
        this.updateTransform();
    }

    handleTransitionEnd() {
        const firstReal = this.originalCount;
        const lastReal = this.originalCount * 2 - 1;

        if (this.currentIndex < firstReal) {
            this.currentIndex = lastReal;
            this.jumpTo(this.currentIndex, false);
        } else if (this.currentIndex > lastReal) {
            this.currentIndex = firstReal;
            this.jumpTo(this.currentIndex, false);
        }

        this.isAnimating = false;
    }

    jumpTo(index, animate = true) {
        this.track.style.transition = animate ? 'transform 0.45s cubic-bezier(0.22, 0.61, 0.36, 1)' : 'none';
        this.currentIndex = index;
        this.updateTransform();
    }

    updateTransform() {
        const translateX = -this.currentIndex * this.step;
        this.track.style.transform = `translateX(${translateX}px)`;
    }

    handleResize() {
        const previousStep = this.step;
        this.setStep();
        if (previousStep !== this.step) {
            this.jumpTo(this.currentIndex, false);
        }
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const navbarWrapper = document.querySelector('.navbar-wrapper');
    const fadeElements = document.querySelectorAll('.fade-in-left');
    const newsletterForm = document.querySelector('.newsletter-form');
    const scrollToTopBtn = document.getElementById('scrollToTop');
    const arrivalCarousel = document.getElementById('arrivalCarousel');

    const toggleStickyNav = () => {
        if (!navbarWrapper) return;
        navbarWrapper.classList.toggle('sticky', window.scrollY > 50);
    };

    const toggleScrollButton = () => {
        if (!scrollToTopBtn) return;
        scrollToTopBtn.classList.toggle('show', window.scrollY > 300);
    };

    window.addEventListener('scroll', () => {
        toggleStickyNav();
        toggleScrollButton();
    });
    toggleStickyNav();
    toggleScrollButton();

    if (fadeElements.length) {
        if ('IntersectionObserver' in window) {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach((entry) => {
                    if (entry.isIntersecting) {
                        setTimeout(() => entry.target.classList.add('visible'), 50);
                    } else {
                        entry.target.classList.remove('visible');
                    }
                });
            }, {
                threshold: 0.15,
                rootMargin: '0px 0px -50px 0px'
            });

            fadeElements.forEach((element) => observer.observe(element));
        } else {
            fadeElements.forEach((element, index) => {
                setTimeout(() => element.classList.add('visible'), index * 100);
            });
        }
    }

    if (newsletterForm) {
        newsletterForm.addEventListener('submit', handleNewsletterSubmit);
    }

    if (scrollToTopBtn) {
        scrollToTopBtn.addEventListener('click', (event) => {
            event.preventDefault();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }

    if (arrivalCarousel) {
        new SeamlessCarousel(arrivalCarousel);
    }

    // Video scroll/ScrollTrigger logic (moved into the same DOMContentLoaded handler)
    const video = document.getElementById("scrollVideo");
    const nextContent = document.querySelector(".next-content");

    if (video) {
        let duration = 0;
        video.pause();

        video.addEventListener("loadedmetadata", () => {
            duration = video.duration || 0;
        });

        // Only create ScrollTrigger on desktop (larger screens)
        if (window.innerWidth > 768 && typeof ScrollTrigger !== 'undefined') {
            ScrollTrigger.create({
                trigger: "#scrollVideoSection",
                start: "top top",
                end: "+=3000",
                scrub: 0.1,
                pin: true,
                onUpdate: (self) => {
                    if (!duration) return;
                    const clampedProgress = Math.min(Math.max(self.progress, 0), 1);
                    const targetTime = clampedProgress * duration;
                    video.currentTime = targetTime;
                },
                onEnter: () => {
                    if (navbarWrapper) {
                        navbarWrapper.classList.add("hidden");
                    }
                },
                onLeave: () => {
                    if (navbarWrapper) {
                        navbarWrapper.classList.remove("hidden");
                    }
                    if (nextContent) {
                        nextContent.classList.add("show");
                    }
                },
                onEnterBack: () => {
                    if (navbarWrapper) {
                        navbarWrapper.classList.add("hidden");
                    }
                    if (nextContent) {
                        nextContent.classList.remove("show");
                    }
                },
                onLeaveBack: () => {
                    if (navbarWrapper) {
                        navbarWrapper.classList.remove("hidden");
                    }
                }
            });
        } else {
            // On mobile, just show the video normally
            video.play().catch(() => {});
            if (nextContent) {
                nextContent.classList.add('show');
            }
        }
    }

});

function handleNewsletterSubmit(event) {
    event.preventDefault();
    const emailInput = event.target.querySelector('.newsletter-input');
    const email = emailInput.value.trim();

    if (!email) {
        return;
    }

    alert('Thank you for subscribing! We\'ll keep you updated with our latest collections and exclusive offers.');
    emailInput.value = '';
}