const express = require("express");
const multer = require("multer");
const { spawn } = require("child_process");
const path = require("path");

const app = express();

// 配置 multer 的 storage 选项
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "uploads/");
    },
    filename: (req, file, cb) => {
        cb(null, `${file.fieldname}_${Date.now()}${path.extname(file.originalname)}`);
    },
});

const upload = multer({ storage });

app.use(express.static("public"));
app.use(express.static(__dirname));

app.post("/upload", upload.single("excelFile"), (req, res) => {
    console.log("Received request");

    const filePath = path.resolve(req.file.path); // 使用 path.resolve 获取文件的绝对路径

    const data_file_path1 = filePath;
    const sheet_name1 = "Sheet1";
    const range1 = "A2:Q9999";

    const data_file_path2 = filePath;
    const sheet_name2 = "Sheet2";
    const range2 = "A2:P9999";

    const cmd = `matlab -nodisplay -nosplash -r "total('${data_file_path1}', '${sheet_name1}', '${range1}', '${data_file_path2}', '${sheet_name2}', '${range2}'); exit;"`;

    const process = spawn(cmd, { shell: true });

    process.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
    });

    process.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });

    process.on('close', (code) => {
        console.log(`子进程退出，退出码 ${code}`);
        if(code !== 0) {
            // 如果子进程非正常退出，返回一个错误状态码和简单的错误信息
            return res.status(500).send("An error occurred during MATLAB processing.");
        }
        // 如果子进程正常退出，返回一个成功状态码和消息
        return res.status(200).send("MATLAB processing completed successfully.");
    });
});

app.get("/matlab-output", (req, res) => {
    const imagePaths = [
        "bp_comparison.png",
        "bp_error.png",
        "error_results.png",
        "error_distribution.png",
        "future_prediction.png",
        "test_results.png"
    ];

    const imageTags = imagePaths
        .map((imagePath) => `<img src="${imagePath}" class="zoomable-image" />`)
        .join("");

    res.send(imageTags);
});

app.listen(3000, () => {
    console.log("Server running on http://localhost:3000");
});
