$(document).ready(function () {
  $('.datatable').DataTable({
    fixedHeader: true,
    info: false,
    paging: false,
    columnDefs: [
      { targets: 'no-sort', orderable: false }
    ]
  });
});
