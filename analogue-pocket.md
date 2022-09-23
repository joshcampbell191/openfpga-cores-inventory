---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
title: Analogue Pocket
---
<script>
  function sortTable() {
    const tableBody = document.querySelector("tbody");
    const tableRows = tableBody.querySelectorAll("tr");
    [...tableRows]
      .sort((a, b) => a.innerText > b.innerText ? 1 : -1)
      .forEach(row => tableBody.appendChild(row))
  }
  document.addEventListener("DOMContentLoaded", sortTable)
</script>

The [Analogue Pocket](https://www.analogue.co/pocket) is a multi-video-game-system portable handheld designed and built by [Analogue](https://www.analogue.co).

## Cores

| Name | Author | Release | Release Date |
| ---- | ------ | ------- | ------------ |
{% for repo in site.data.repos -%}
{% for core in repo.cores -%}
| [{{ core.display_name }}](https://github.com/{{ repo.user }}/{{ core.project }}) | [{{ repo.user }}](https://github.com/{{ repo.user }}) | [![release](https://img.shields.io/github/v/release/{{ repo.user }}/{{ core.project }}?include_prereleases)](https://github.com/{{ repo.user }}/{{ core.project }}/releases/latest) | ![GitHub Release Date](https://img.shields.io/github/release-date-pre/{{ repo.user }}/{{ core.project }}) |
{% endfor -%}
{% endfor -%}
