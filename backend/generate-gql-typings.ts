import { GraphQLDefinitionsFactory } from '@nestjs/graphql';
import { join } from 'path';

const definitionsFactory = new GraphQLDefinitionsFactory();

try {
  void definitionsFactory.generate({
    typePaths: [join(process.cwd(), '../schema/**/*.graphql')],
    path: join(process.cwd(), 'src/graphql.ts'),
    outputAs: 'interface',
  });
} catch (e) {
  console.error('Failed to generate gql schema: ', e);
}
