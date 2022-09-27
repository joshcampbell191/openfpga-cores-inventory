$(document).ready(function() {
  $('.datatable').DataTable({
    fixedHeader: true,
    info: false,
    paging: false,
    scrollX: true,
    columnDefs: [
      { targets: 'no-sort', orderable: false }
    ]
  });
});
