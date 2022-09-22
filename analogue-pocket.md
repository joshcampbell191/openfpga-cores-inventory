---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
title: Analogue Pocket
---

The [Analogue Pocket](https://www.analogue.co/pocket) is a multi-video-game-system portable handheld designed and built by [Analogue](https://www.analogue.co).

## Cores

| Name | Author | Release | Release Date |
| ---- | ------ | ------- | ------------ |
{% for repo in site.data.repos -%}
| [{{ repo.display_name }}](https://github.com/{{ repo.repo.user }}/{{ repo.repo.project }}) | [{{ repo.repo.user }}](https://github.com/{{ repo.repo.user }}) | [![release](https://img.shields.io/github/v/release/{{ repo.repo.user }}/{{ repo.repo.project }}?include_prereleases)](https://github.com/{{ repo.repo.user }}/{{ repo.repo.project }}/releases/latest) | ![GitHub Release Date](https://img.shields.io/github/release-date-pre/{{ repo.repo.user }}/{{ repo.repo.project }}) |
{% endfor -%}
