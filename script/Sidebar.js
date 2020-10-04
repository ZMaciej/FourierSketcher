function setupSidebar()
{
    $('#dismiss, .overlay').on('click', hideSidebar);
    $('#sidebarCollapse').on('click', showSidebar);
    $('#sidebar').on('swipeleft', hideSidebar);
}

function showSidebar()
{
    // open sidebar
    $('#sidebar').addClass('active');
    // fade in the overlay
    $('.overlay').addClass('active');
    $('.collapse.in').toggleClass('in');
    $('#sidebar').focus();
}

function hideSidebar()
{
    // hide sidebar
    $('#sidebar').removeClass('active');
    // hide overlay
    $('.overlay').removeClass('active');
}