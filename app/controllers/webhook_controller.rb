class WebhookController < ApplicationController
    protect_from_forgery with: :null_session # CSRF対策無効化
     
     CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
     OUTBOUND_PROXY = ENV['LINE_OUTBOUND_PROXY']
     CHANNEL_ACCESS_TOKEN = ENV['LINE_CHANNEL_ACCESS_TOKEN']
     
     def callback
        unless is_validate_signature
         render :nothing => true, status: 470
        end
        
        event = params["events"][0]
        event_type = event["type"]
        replyToken = event["replyToken"]
        
        case event_type
        when "message"
            input_text = event["message"]["text"]
            
            if input_text == "サンシャイン"
                input_text = "空前絶後のォォォォ！！！！"
            end
            
            output_text = input_text
        end

        client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
        res = client.reply(replyToken, output_text)
        
        if res.status == 200
            logger.info({success: res})
        else
            logger.info({fail: res})
        end
        
        render :nothing => true, status: :ok
     end
     
     private
     # LINEからのアクセスか確認
     # 認証に成功すればtrueを返す
     def is_validate_signature
         signature = request.headers["X-LINE-Signature"]
         http_request_body = request.raw_post
         hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
         signature_answer = Base64.strict_encode64(hash)
         signature == signature_answer
     end
 end