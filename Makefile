bindgen: llvm-config
	odin build src -out:bindgen

llvm-config:
	find . -type f -name "*.odin" -exec sed -i "s/system:clang\"/system:clang-$$(llvm-config --version | cut -d. -f1)\"/g" {} +

clean:
	rm -f bindgen
