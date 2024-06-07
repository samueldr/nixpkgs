#!/usr/bin/env ruby

# Checking the output validity:
#
# ```
#  $ ./dump-compatibles.rb result/ > mapping-auto.dtsi
#  $ cpp -nostdinc -undef -x assembler-with-cpp mapping.dts | dtc --force > mapping.dtb
#  $ dtc --force --sort mapping.dtb | less
# ```
#

require "shellwords"

class String
  def indent()
    self.split("\n").map do |line|
      "\t#{line}"
    end
    .join("\n")
  end
end

def fdtget(file, node, property)
  cmd = [
    "fdtget",
    file,
    node,
    property,
  ]
  " $ #{cmd.shelljoin}"
  `#{cmd.shelljoin}`.strip()
end

data = []

Dir.chdir(File.join(ARGV.first, "dtbs")) do
  Dir.glob("**/*.dtb").each do |path|
    model = fdtget(path, "/", "model")
    compatibles = fdtget(path, "/", "compatible").split(/\s+/)
    node = path.gsub("/", "@").sub(/\.dtb$/, "")
    data << {
      path: path,
      node: node,
      model: model,
      compatible: compatibles.first,
      compatibles: compatibles,
    }
  end
end

data = data
  .sort { |a, b| a[:path] <=> b[:path] }
  .group_by { |dtb| dtb[:compatible] }


singles, multiples = data.partition { |key, group| group.count == 1 }

by_socvendor = singles.to_h.values.map(&:first).group_by do |dtb|
  dtb[:path].split("/").first
end

def dump_mappings(data)
  [
    "mapping {",
    *data.map do |dtb|
      [
        "/* #{dtb[:model]}: #{dtb[:compatibles].inspect} */",
        "#{dtb[:node]} {",
          %Q{\tdtb = #{dtb[:path].inspect};},
          %Q{\tmodel = #{dtb[:model].inspect};},
          %Q{\tcompatible = #{dtb[:compatible].inspect};},
        "};",
      ].join("\n").indent()
    end.join("\n"),
    "};",
  ].join("\n")
end

warnings =
  if multiples.count == 0
    "/* No warnings during generation */"
  else
    [
      "/*",
      " * WARNING: These dtb files share the first compatible names.",
      " *          No action has been taken for them.",
      multiples.to_h.map do |compatible, data|
        [
        " *",
        " * - #{compatible}",
        data.map do |dtb|
          " *     - #{dtb[:path]}"
        end.join("\n"),
        ].join("\n")
      end,
      " */",
    ].join("\n")
  end

puts <<EOF
/dts-v1/;

/ {
  fdtshim,schema-version = "0.1";
  fdtshim,generator = "dump-compatibles.rb";
  compatible = "fdtshim,mapping";
};

#{warnings}
#{
by_socvendor.map do |vendor, data|
  [
    "",
    "/*",
    " * #{vendor}",
    " */",
    "/ {",
    dump_mappings(data).indent(),
    "};",
  ]
end.join("\n")
}
EOF
