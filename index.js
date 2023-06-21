const express = require("express");
const multer = require("multer");
const { exec } = require("child_process");
const app = express();
const upload = multer({ dest: "uploads/" });

app.use(express.static("public"));

app.post("/upload", upload.single("excelFile"), (req, res) => {
	const filePath = req.file.path;
	console.log("获取到地址: ", filePath);
	exec(
		`matlab -nodisplay -nosplash -r "data = processExcel('${filePath}'); disp(jsonencode(data)); exit;"`,
		(error, stdout, stderr) => {
			if (error) {
				console.error(`执行错误: ${error}`);
				console.error(`错误输出: ${stderr}`);
				return;
			}
			console.log("标准输出:", stdout);
			try {
				console.log("解析 JSON:", JSON.parse(stdout));
				res.json(JSON.parse(stdout));
			} catch (e) {
				console.error("解析 JSON 错误:", e);
			}
		}
	);
});

app.listen(3000, () => {
	console.log("Server running on http://localhost:3000");
});
