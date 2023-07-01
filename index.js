const express = require("express");
const multer = require("multer");
const { spawn } = require("child_process");
const path = require("path");
const fs = require("fs").promises;

const app = express();

// 配置 multer 的 storage 选项
const storage = multer.diskStorage({
	destination: (req, file, cb) => {
		cb(null, "uploads/");
	},
	filename: (req, file, cb) => {
		cb(
			null,
			`${file.fieldname}_${Date.now()}${path.extname(file.originalname)}`
		);
	},
});

const upload = multer({ storage });

app.use(express.static("public"));
app.use(express.static(__dirname));

app.post("/upload", upload.single("excelFile"), async (req, res) => {
	console.log("Received request");

	// 图片路径
	try {
		const files = await fs.readdir(__dirname);
		// 筛选出 .png 文件
		const imagePaths = files.filter(
			(file) => path.extname(file).toLowerCase() === ".png"
		);

		// 删除所有的 .png 文件
		for (const imagePath of imagePaths) {
			try {
				await fs.unlink(path.join(__dirname, imagePath));
				console.log(`Successfully deleted old image ${imagePath}`);
			} catch (err) {
				if (err.code !== "ENOENT") {
					console.error(`Error while deleting old image ${imagePath}:`, err);
				}
			}
		}

		const filesInUploads = await fs.readdir("uploads/");
		const xlsxFiles = await Promise.all(
			filesInUploads
				.filter((file) => path.extname(file).toLowerCase() === ".xlsx")
				.map(async (file) => {
					const filePath = path.join("uploads/", file);
					const stats = await fs.stat(filePath);
					return { file: filePath, mtime: stats.mtime };
				})
		);

		if (xlsxFiles.length > 6) {
			xlsxFiles
				.sort((a, b) => a.mtime.getTime() - b.mtime.getTime())
				.slice(0, xlsxFiles.length - 6)
				.forEach(async (fileStat) => {
					try {
						await fs.unlink(fileStat.file);
						console.log(`Successfully deleted old file ${fileStat.file}`);
					} catch (err) {
						console.error(
							`Error while deleting old file ${fileStat.file}:`,
							err
						);
					}
				});
		}
	} catch (err) {
		console.error(
			`Error while reading directory or deleting old files: ${err}`
		);
	}

	const filePath = path.resolve(req.file.path); // 使用 path.resolve 获取文件的绝对路径

	const data_file_path1 = filePath;
	const sheet_name1 = "Sheet1";
	const range1 = "A2:Q9999";

	const data_file_path2 = filePath;
	const sheet_name2 = "Sheet2";
	const range2 = "A2:P9999";

	const cmd = `matlab -nodisplay -nosplash -r "total('${data_file_path1}', '${sheet_name1}', '${range1}', '${data_file_path2}', '${sheet_name2}', '${range2}'); exit;"`;

	const process = spawn(cmd, { shell: true });

	process.stdout.on("data", (data) => {
		console.log(`stdout: ${data}`);
	});

	process.stderr.on("data", (data) => {
		console.error(`stderr: ${data}`);
	});

	process.on("close", (code) => {
		console.log(`子进程退出，退出码 ${code}`);
		if (code !== 0) {
			// 如果子进程非正常退出，返回一个错误状态码和简单的错误信息
			return res
				.status(500)
				.send("An error occurred during MATLAB processing.");
		}
		// 如果子进程正常退出，返回一个成功状态码和消息
		return res.status(200).send("MATLAB processing completed successfully.");
	});
});

app.get("/matlab-output", async (req, res) => {
	try {
		const files = await fs.readdir(__dirname); // 使用 promises 版本的 readdir

		// 筛选出 .png 文件
		const imagePaths = files.filter(
			(file) => path.extname(file).toLowerCase() === ".png"
		);

		console.log('imagePaths ', imagePaths)

		// 生成 HTML 图像标签
		const imageTags = imagePaths
			.map((imagePath) => `<img src="/${imagePath}" class="zoomable-image" />`) // 图片路径必须是完整的 URL 路径
			.join("");

		res.send(imageTags);
	} catch (err) {
		console.error(`Error reading directory: ${err}`);
		res.status(500).send("An error occurred while reading the directory.");
	}
});

app.listen(3000, () => {
	console.log("Server running on http://localhost:3000");
});
