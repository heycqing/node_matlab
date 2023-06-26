document.getElementById("fileInput").addEventListener("change", (event) => {
	const file = event.target.files[0];
	const formData = new FormData();
	formData.append("excelFile", file);

	const progressBarContainer = document.getElementById("progressBarContainer");
	const progressBar = document.getElementById("progressBar");
	progressBar.style.width = "0%";
	progressBarContainer.style.display = "block";

	const xhr = new XMLHttpRequest();
	xhr.open("POST", "/upload", true);

	// Handle progress
	xhr.upload.onprogress = function (event) {
		if (event.lengthComputable) {
			const percentCompleted = Math.round((event.loaded * 100) / event.total);
			progressBar.style.width = percentCompleted + "%";
		}
	};

    document.getElementById('statusContainer').style.display = "flex";

	// Handle response
	xhr.onload = function () {
		if (xhr.status === 200) {
			statusText.textContent = "结果已生成";
			statusColon.style.display = "none";
			progressBarContainer.style.display = "none";
			fetch("/matlab-output")
				.then((response) => response.text())
				.then((data) => {
					document.getElementById("imageContainer").innerHTML = data;
					const zoomableImages = document.querySelectorAll(".zoomable-image");
					mediumZoom(zoomableImages, {
						margin: 24,
					});

                    document.getElementById('uploadBtnWrapper').style.display = "none";
				});
		}
	};

	xhr.send(formData);
});
