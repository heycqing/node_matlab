const { exec } = require("child_process");

exec(
	`matlab -nodisplay -nosplash -r "disp('Hello, MATLAB!'); exit;"`,
	(error, stdout, stderr) => {
		if (error) {
			console.error(`执行错误: ${error}`);
			console.error(`错误输出: ${stderr}`);
			return;
		}
		console.log("标准输出:", stdout);
	}
);
