document.addEventListener('DOMContentLoaded', function() {
    let toggler = document.querySelector('.navbar-toggler');
    let navbarCollapse = document.querySelector('#navbarScroll');

    toggler.addEventListener('click', function() {
        navbarCollapse.classList.toggle('show');
    });
});
