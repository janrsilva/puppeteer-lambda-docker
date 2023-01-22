const puppeteer = require("puppeteer");
const args = require("./args");
const PuppeteerVideoRecorder = require('puppeteer-video-recorder');
const recorder = new PuppeteerVideoRecorder();
const fs = require('fs');
const { exec } = require("child_process");
const { promisify } = require('util');
const execPromise = promisify(exec);

//print node version
console.log('Node version:', process.version)
console.log('Lambda Name:', process.env.AWS_LAMBDA_FUNCTION_NAME)

async function command(cmd) {
  console.log('exec command:', cmd);
  return execPromise(cmd).then(
    ({ stdout, stderr }) => {
      console.log('stdout:', stdout);
      console.log('stderr:', stderr);
      return stdout.trim().replace(/\n$/, '');
    }
  ).catch(console.error)
}

exports.lambdaHandler = async (event, context, callback) => {
  const url = "https://google.com";

  try {
    const viewportOptions = {
      args,
      defaultViewport: null,
      executablePath: await command('which chromium-browser'),
      headless: true,
    }

    const browser = await puppeteer.launch(viewportOptions)

    const page = await browser.newPage()
    const videosPath = '/tmp/';

    await recorder.init(page, videosPath);
    await recorder.start();

    await page.goto(url, { waitUntil: ['domcontentloaded', 'networkidle0'] })

    await recorder.stop();
    const { videoFilename } = recorder.fsHandler;
    const fileBuffer = fs.readFileSync(videoFilename);
    const fileName = videoFilename.split('/').pop();
    const extension = fileName.split('.').pop();

    console.log('Page loaded', {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      input: event,
      fileName,
      extension,
    })

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Go Serverless v1.0! Your function executed successfully!',
        input: event,
        fileName,
        extension,
      }),
    };

    //upload fileBuffer to s3 or other storage
    // fileBuffer
  } catch (error) {
    console.log(error)
  }

  return {
    statusCode: 500,
    body: JSON.stringify({
      message: 'Go Serverless v1.0! Your function got error!',
      input: event,
    }),
  };

}
//exports.lambdaHandler();