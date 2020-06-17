# frozen_string_literal: true
module Geoserver
  module Publish
    class DataStore
      attr_reader :connection

      def initialize(conn = nil)
        @connection = conn || Geoserver::Publish::Connection.new
      end

      def delete(workspace_name:, data_store_name:)
        path = data_store_url(workspace_name: workspace_name, data_store_name: data_store_name)
        connection.delete(path: path)
      end

      def find(workspace_name:, data_store_name:)
        path = data_store_url(workspace_name: workspace_name, data_store_name: data_store_name)
        out = connection.get(path: path)
        JSON.parse(out) if out
      end

      def create(workspace_name:, data_store_name:, url:)
        path = data_store_url(workspace_name: workspace_name, data_store_name: nil)
        payload = payload_new(data_store_name: data_store_name, url: url)
        connection.post(path: path, payload: payload)
      end

      def upload(workspace_name:, data_store_name:, file:)
        content_type = 'application/zip'
        path = upload_url(workspace: workspace_name, data_store: data_store_name)
        connection.put(path: path, payload: file, content_type: content_type)
      end

      private

        def data_store_url(workspace_name:, data_store_name:)
          last_path_component = data_store_name ? "/#{data_store_name}" : ""
          "workspaces/#{workspace_name}/datastores#{last_path_component}"
        end

        def upload_url(workspace:, data_store:)
          "workspaces/#{workspace}/datastores/#{data_store}/file.shp"
        end

        # rubocop:disable Metrics/MethodLength
        def payload_new(data_store_name:, url:)
          {
            dataStore: {
              name: data_store_name,
              connectionParameters: {
                entry: [
                  {
                    "@key": "create spatial index",
                    "$": "true"
                  },
                  {
                    "@key": "url",
                    "$": url
                  },
                  {
                    "@key": "cache and reuse memory maps",
                    "$": "false"
                  }
                ]
              }
            }
          }.to_json
        end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
