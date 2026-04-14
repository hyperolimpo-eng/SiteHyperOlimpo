/* ==========================================================================
   JavaScript Principal - TechSolutions Landing Page
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Inicializar Ícones Lucide
    lucide.createIcons();

    // 2. Elementos DOM
    const navbar = document.getElementById('navbar');
    const menuToggle = document.getElementById('menu-toggle');
    const navLinks = document.getElementById('nav-links');
    const yearSpan = document.getElementById('year');
    const reveals = document.querySelectorAll('.reveal');
    const animates = document.querySelectorAll('.animate-up');

    // 3. Atualizar ano no Footer
    if (yearSpan) {
        yearSpan.textContent = new Date().getFullYear();
    }

    // 4. Menu Responsivo Mobile
    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');

            // Trocar ícone do menu (menu <-> x)
            const icon = navLinks.classList.contains('active') ? 'x' : 'menu';
            menuToggle.innerHTML = `<i data-lucide="${icon}"></i>`;
            lucide.createIcons();
        });

        // Fechar menu ao clicar num link
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('active');
                menuToggle.innerHTML = '<i data-lucide="menu"></i>';
                lucide.createIcons();
            });
        });
    }

    // 5. Scroll Events (Navbar + Animações/Reveals)
    const handleScroll = () => {
        // Navbar glass effect e shrink
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }

        // Reveal Elements no Scroll
        const windowHeight = window.innerHeight;
        const revealPoint = 100; // Pixels antes de aparecer

        reveals.forEach(reveal => {
            const revealTop = reveal.getBoundingClientRect().top;
            if (revealTop < windowHeight - revealPoint) {
                reveal.classList.add('active');
            }
        });
    };

    // Iniciar animações do Hero logo na carga
    setTimeout(() => {
        animates.forEach(el => el.classList.add('active'));
    }, 100);

    // Adicionar Listener
    window.addEventListener('scroll', handleScroll);
    handleScroll(); // Disparar uma vez na inicialização
});
