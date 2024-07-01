class Version {
  static redirect(id) {
    const select = document.getElementById(id);
    const new_version = select.options[select.selectedIndex].text;

    for (const version of g_versions) {
      if (location.href.includes(version)) {
        window.location.href = window.location.href.replace(version, new_version);
        break;
      }
    }
  }

  static init(id) {
    const select = document.getElementById(id);
    const pv = localStorage.getItem('version')
    for (const v of g_versions) {
      var option = document.createElement('option');
      option.value = v;
      option.innerHTML = v;
      select.appendChild(option);

      if (location.href.includes(v))
        option.setAttribute("selected", "");
    }
  }
}
