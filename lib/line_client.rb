require "faraday"
require "faraday_middleware"
require "json"
require "pp"

class LineClient
    END_POINT = "https://api.line.me"
    
    def initialize(channel_access_token, proxy = nil)
        @channel_access_token = channel_access_token
        @proxy = proxy
    end
    
    def post(path, data)
        client = Faraday.new(:url => END_POINT) do |conn|
            conn.request :json
            conn.response :json, :content_type => /\bjson$/
            conn.adapter Faraday.default_adapter
            conn.proxy @proxy
        end
        
        res = clinet.post do |request|
            request.url path
            request.headers = {
                'ContentType' => 'application/json; charset=UTF-8',
                'Authorization' => "Bearer #{@channel_access_token}"
            }
            request.body = data
        end
        res
    end
    
    def reply(replyToken, text)
        messages = [
            {
                "type" => "text",
                "text" => text
            }
        ]
    
        body = {
            "replyToken" => replyToken,
            "messages" => messages
        }
        post('/v2/bot/message/reply', body.to_json)
    end
    
    def send(line_ids, message)
        post('/v1/events',{
            to: line_ids,
            content: {
                contentType: ContentType::TEXT,
                toType: ToType::USER,
                text: message
            },
            toChannel: TO_CHANNEL,
            eventType: EVENT_TYPE
        })
    end
end
