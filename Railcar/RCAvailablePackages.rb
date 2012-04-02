#
#  RCAvailablePackages.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/31/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCAvailablePackages
  PACKAGES = {
    "db" => [
      {
        :name => "MySQL", 
        :description => "The most popular open-source SQL database",
        :image => "mysql.png",
        :brewName => "mysql"
      },
      {
        :name => "PostgreSQL",
        :description => "High-capacity, high-performance SQL database",
        :image => "pgsql.png",
        :brewName => "postgresql"
      },
      {
        :name => "MongoDB",
        :description => "Scalable, high-performance, open source NoSQL database",
        :image => "mongo.png",
        :brewName => "mongodb"
      },
      {
        :name => "Redis",
        :description => "Massively scalable key/value store",
        :image => "redis.png",
        :brewName => "redis"
      },
      {
        :name => "Riak",
        :description => "Highly scalable, fault-tolerant distributed database",
        :image => "riak.png",
        :brewName => "riak"
      },
      {
        :name => "Memcached",
        :description => "High-performance, distributed memory object caching system",
        :image => "memcached.png",
        :brewName => "memcached"
      },
      {
        :name => "Apache CouchDB",
        :description => "Document-oriented database",
        :image => "couchdb.png",
        :brewName => "couchdb"
      }
    ],
    "language" => [
      {
        :name => "Node.js",
        :description => "Network application platform envrionment implemented on Chrome's JavaScript runtime",
        :image => "node.png",
        :brewName => "node"
      },
      {
        :name => "Clojure",
        :description => "A dynamic functional programming language targeting the JVM",
        :image => "clojure.png",
        :brewName => "clojure"
      },
      {
        :name => "Python",
        :description => "Modern object-oriented dynamic language",
        :image => "python.png",
        :brewName => "python"
      },
      {
        :name => "Scala",
        :description => "Concise programming language targeting the JVM",
        :image => "scala.png",
        :brewName => "scala"
      },
      {
        :name => "Erlang",
        :description => "Programming language geared towards massively scalable soft real-time systems",
        :image => "erlang.png",
        :brewName => "erlang"
      },
      {
        :name => "Python 3.0",
        :description => "Feature forward version of Python",
        :image => "python.png",
        :brewName => "python3"
      }
    ],
    "lib" => [
      {
        :name => "libxml",
        :description => "Portable XML parsing library",
        :brewName => "libxml"
      },
      {
        :name => "libxslt",
        :description => "Portable XSLT library",
        :brewName => "libxslt"
      },
      {
        :name => "libiconv",
        :description => "Library for converting among encodings",
        :brewName => "libiconv"
      },
      {
        :name => "imagemagick",
        :description => "Image manipulation and compositing",
        :brewName => "imagemagick"
      }
    ]
  }
  
  def self.inCategory(category)
    PACKAGES[category]
  end
end