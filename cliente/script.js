document.addEventListener("DOMContentLoaded", () => {
  const drawer = document.getElementById("drawer");
  const menuToggle = document.getElementById("menuToggle");
  const overlay = document.getElementById("overlay");

  // === MENÚ HAMBURGUESA (drawer) ===
  if (drawer && menuToggle) {
    menuToggle.addEventListener("click", () => {
      drawer.classList.toggle("open");
      if (overlay) overlay.classList.toggle("show");
    });

    if (overlay) {
      overlay.addEventListener("click", () => {
        drawer.classList.remove("open");
        overlay.classList.remove("show");
      });
    }
  }

  // === MODAL DE COBRO (index.html) ===
  const modalCobro = document.getElementById("modalCobro");
  const cobroCard = document.querySelector('.card-container .card:nth-child(1)');
  if (modalCobro && cobroCard) {
    cobroCard.addEventListener("click", () => {
      modalCobro.style.display = "flex";
      if (overlay) overlay.classList.add("show");
    });

    window.addEventListener("click", (e) => {
      if (e.target === modalCobro) {
        modalCobro.style.display = "none";
        if (overlay) overlay.classList.remove("show");
      }
    });
  }

  // === MODAL DE CLIENTE (cobro.html) ===
  const modal = document.getElementById("modal"); // modal general de cobro.html
  const openModalBtn = document.querySelector(".finalize-btn");

  if (modal && openModalBtn) {
    openModalBtn.addEventListener("click", () => {
      modal.style.display = "flex";
    });

    window.addEventListener("click", (e) => {
      if (e.target === modal) {
        modal.style.display = "none";
      }
    });

    // Define función global para botón "Cancelar"
    window.closeModal = function () {
      modal.style.display = "none";
    };
  }
  const btnSiguiente = document.querySelector(".btn-siguiente");

  if (btnSiguiente) {
    btnSiguiente.addEventListener("click", (e) => {
      e.preventDefault();

      Swal.fire({
        title: '🔍 Revisar atentamente el producto 🐱.',
        html: '¿El/Los productos se encuentran en buenas condiciones?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'SI',
        cancelButtonText: 'NO',
        confirmButtonColor: '#b2fcd2',
        cancelButtonColor: '#ff6b6b'
      }).then((result) => {
        if (result.isConfirmed) {
          Swal.fire({
            icon: 'success',
            title: '💵 Entrega el reembolso',
            html: 'Entrega la cantidad <strong>$--</strong> según el método de reembolso seleccionado.',
            confirmButtonText: 'OK',
            confirmButtonColor: '#b2fcd2'
          });
        } else {
          Swal.fire({
            icon: 'error',
            title: 'Reembolso cancelado',
            text: 'El producto no se encuentra en condiciones aceptables.',
            confirmButtonColor: '#ff6b6b'
          });
        }
      });
    });
  }
// Tarjeta Cambiar Contraseña con SweetAlert
const cambiarCard = document.querySelector('.card:nth-child(2)');

if (cambiarCard) {
  cambiarCard.addEventListener("click", () => {
    Swal.fire({
      title: 'Ha solicitado un cambio de contraseña.',
      text: '¿Desea continuar?',
      icon: 'question',
      showCancelButton: true,
      confirmButtonText: 'SI',
      cancelButtonText: 'NO',
      confirmButtonColor: '#b2fcd2',
      cancelButtonColor: '#ff6b6b'
    }).then((result) => {
      if (result.isConfirmed) {
        window.location.href = "cambiar.html";
      }
    });
  });
}




});
