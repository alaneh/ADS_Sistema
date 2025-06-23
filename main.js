  function openModal() {
    document.getElementById("modal").style.display = "flex";
  }

  function closeModal() {
    document.getElementById("modal").style.display = "none";
  }

  // Cierra el modal al hacer clic fuera del contenido
  window.onclick = function(event) {
    const modal = document.getElementById("modal");
    if (event.target === modal) {
      closeModal();
    }
  }